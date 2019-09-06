module gopay;

public import gopay.definition;
public import gopay.token;
public import gopay.http;
import std.base64;
import vibe.data.json;

interface IAuth
{
    AccessToken authorize();
}

class OAuth2 : IAuth
{
    private GoPay gopay;

    this(GoPay g)
    {
        gopay = g;
    }

    AccessToken authorize()
    {
        import std.conv : to;        
        auto authenticator = new BasicAuthentication(gopay.getConfig("clientId"), gopay.getConfig("clientSecret"));
        Response response = gopay.call(
            "oauth2/token",
            GoPay.FORM,
            RequestMethods.post,
            authenticator,
            ["grant_type" : "client_credentials", "scope" :  gopay.getConfig("scope")]
        );
        auto t = new AccessToken;
        t.response = response;
        if (response.code == 200)
        {
            auto bodyData = response.responseBody.toString;
            auto jsonData = bodyData.parseJson;
            t.token = jsonData["access_token"].to!string;
            t.expirationDate = Clock.currTime + dur!"seconds"(jsonData["expires_in"].to!uint);
        }
        return t;
    }

    string getClient()
    {
        return gopay.getConfig("clientId") ~ gopay.getConfig("isProductionMode") ~ gopay.getConfig("scope");
    }
}

class GoPay
{

    enum JSON = "application/json";
    enum FORM = "application/x-www-form-urlencoded";

    const LOCALE_CZECH = "cs-CZ";
    const LOCALE_ENGLISH = "en-US";

    static immutable string[2] urls = ["https://gate.gopay.cz/", "https://gw.sandbox.gopay.com/"];

    private string[string] config;
    Duration timeout;

    public this(string[string] c)
    {
        import std.conv : to;
        config = c;
        timeout = config["timeout"].to!uint.dur!"seconds";
    }

    public string getConfig(string key)
    {
        return this.config[key];
    }

    public auto call(T)(string urlPath, string contentType, string method, Auth authenticator, T[string] data = null)
    {
        Request r;
        string url = this.buildUrl("api/" ~ urlPath);

        r.timeout = timeout;
        r.authenticator = authenticator;
        r.addHeaders(["Accept" : "application/json", "Accept-Language" : this.getAcceptedLanguage()]);
        static if (is(T == string))
        {
            return r.execute(method, url, aa2params(data), contentType);
        }
        else static if (is( T == Json))
        {
            return r.execute(method, url, serializeToJsonString(data), contentType);
        }
        else
        {
            static assert(0); // not supported
        }
    }

    public auto buildUrl(string urlPath)
    {
        import std.uni : toUpper;
        auto isProductionMode = this.getConfig("isProductionMode").toUpper;
        size_t index = 1;
        switch (isProductionMode)
        {
            case "1":            
            case "T":            
            case "TRUE":
            case "Y":
            case "YES":
            case "ON":
                index = 0;
                break;
            default:
                index = 1;
        }

        return urls[1] ~ urlPath;
    }


    private auto getAcceptedLanguage()
    {
        switch (this.getConfig("language"))
        {
            case Language.czech:
            case Language.slovak:
                return this.LOCALE_CZECH;
            default: return this.LOCALE_ENGLISH;
        }
    }
}

auto payments(string[string] userConfig)
{
    import std.experimental.logger;

    auto config = userConfig.mergeAA([
        "scope" : TokenScope.all,
        "language" : Language.english,
        "timeout" : "30",
    ]);
    
    auto gopay = new GoPay(config);
    auto auth = new CachedOAuth(new OAuth2(gopay), new InMemoryTokenCache);
    return new Payments(gopay, auth);
}

// auto paymentsSupercash(array userConfig, array userServices = [])
// {
//     config = userConfig + [
//                     "scope" : Definition\TokenScope::ALL,
//                     "language" : Definition\Language::ENGLISH,
//                     "timeout" : 30
//             ];
//     services = userServices + [
//                     "cache" : new Token\InMemoryTokenCache,
//                     "logger" : new Http\Log\NullLogger
//             ];
//     browser = new Http\JsonBrowser(services["logger"], config["timeout"]);
//     gopay = new GoPay(config, browser);
//     auth = new Token\CachedOAuth(new OAuth2(gopay), services["cache"]);
//     return new PaymentsSupercash(gopay, auth);
// }

private auto mergeAA(AA : T[S],T,S)(auto ref AA aa1, auto ref AA aa2)
{
    T[S] res = aa2.dup;
    foreach(key, ref val; aa1)
    {
        res[key] = val;
    }
    
    return res;
}

class CachedOAuth : IAuth
{
    private OAuth2 oauth;
    private TokenCache cache;

    this(OAuth2 auth, TokenCache cache)
    {
        oauth = auth;
        this.cache = cache;
    }

    public AccessToken authorize()
    {
        auto client = oauth.getClient();
        auto token = cache.getAccessToken(client);
        if ( token is null || token.isExpired) {
            token = oauth.authorize();
            cache.setAccessToken(client, token);
        }
        return token;
    }
}

class Payments
{
    public GoPay gopay;
    public IAuth auth;

    this(GoPay g, IAuth a)
    {
        this.gopay = g;
        this.auth = a;
    }

    public auto createPayment(Json[string] rawPayment)
    {
        auto payment = rawPayment.mergeAA([
            "target" : Json([
                "type" : Json("ACCOUNT"),
                "goid" : Json(this.gopay.getConfig("goid"))
            ]),
            "lang" : Json(this.gopay.getConfig("language"))
        ]);
        return this.post("payments/payment", GoPay.JSON, payment);
    }


    public auto get(string urlPath, string contentType, Json[string] data = null)
    {
        return do_(urlPath, contentType, RequestMethods.get, data);
    }
    
    public auto post(string urlPath, string contentType, Json[string] data = null)
    {
        return do_(urlPath, contentType, RequestMethods.post, data);
    }

    private auto do_ (string urlPath, string contentType, string method, Json[string] data = null)
    {

        auto token = this.auth.authorize();
        if (token.token) {
            auto authenticator = new BearerAuthentication(token.token);
            return this.gopay.call(
                urlPath,
                contentType,                
                method,
                authenticator,
                data
            );
        }
        return token.response;
    }

    public auto getStatus(string id)
    {
        return this.get("payments/payment/" ~ id ~ "", GoPay.FORM);
    }

    /** @see refundPaymentEET */
    public auto refundPayment(T)(string id, T data)
    {    
        static if (isAssociativeArray!T)
            return this.refundPaymentEET(id, data);
        else static if (isNumeric!T)
            return this.post("payments/payment/" ~ id ~ "/refund", GoPay.FORM, ["amount" : Json(data)]);
        else
            static assert(0);
    }

    public auto refundPaymentEET(string id, Json[string] paymentData)
    {
        return this.post("payments/payment/" ~ id ~ "/refund", GoPay.JSON, paymentData);
    }

    public auto createRecurrence(string id, Json[string] payment)
    {
        return this.post("payments/payment/" ~ id ~ "/create-recurrence", GoPay.JSON, payment);
    }

    public auto voidRecurrence(string id)
    {
        return this.post("payments/payment/" ~ id ~ "/void-recurrence", GoPay.FORM, Json.emptyObject);
    }

    public auto captureAuthorization(string id)
    {
        return this.post("payments/payment/" ~ id ~ "/capture", GoPay.FORM, Json.emptyObject);
    }

    public auto captureAuthorizationPartial(string id, Json[string] capturePayment)
    {
        return this.post("payments/payment/" ~ id ~ "/capture", GoPay.JSON, capturePayment);
    }

    public auto voidAuthorization(string id)
    {
        return this.post("payments/payment/" ~ id ~ "/void-authorization", GoPay.FORM, Json.emptyObject);
    }

    public auto getPaymentInstruments(string goid, Currency currency)
    {
        return this.get("eshops/eshop/" ~ goid ~ "/payment-instruments/" ~ currency, null);
    }

    public auto getAccountStatement(array accountStatement)
    {
        return this.post("accounts/account-statement", GoPay.JSON, accountStatement);
    }

    public auto getEETReceiptByPaymentId(paymentId)
    {
        return this.get("payments/payment/{paymentId}/eet-receipts", GoPay.JSON);
    }

    public auto findEETReceiptsByFilter(array filter)
    {
        return this.post("eet-receipts", GoPay.JSON, filter);
    }


    // prepsat metodu api na metody GET a POST, a metode call se bude predavat parametr METHOD

    

    public auto urlToEmbedJs()
    {
        return this.gopay.buildUrl("gp-gw/js/embed.js");
    }

    public auto getGopay()
    {
        return this.gopay;
    }

    public auto getAuth()
    {
        return this.auth;
    }
    
}

public class BearerAuthentication: Auth {
    private {
        string   token;        
    }
    /// Constructor.
    /// Params:
    /// username = username
    /// password = password
    /// domains = not used now
    ///
    this(string token) {
        this.token = token;
    }
    /// create Basic Auth header
    override string[string] authHeaders(string domain) {        
        string[string] auth;
        auth["Authorization"] = "Bearer " ~ token;
        return auth;
    }
    /// returns username
    override string userName() {
        return token;
    }
    /// return user password
    override string password() {
        return token;
    }
}
