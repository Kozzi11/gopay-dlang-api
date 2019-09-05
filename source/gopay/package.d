module gopay;

public import gopay.definition;
public import gopay.token;
public import gopay.http;
import std.base64;
import vibe.data.json;

interface Auth
{
    AccessToken authorize();
}

class OAuth2 : Auth
{
    private GoPay gopay;

    this(GoPay g)
    {
        gopay = g;
    }

    AccessToken authorize()
    {
        import std.conv : to;
        auto credentials = "{" ~ gopay.getConfig("clientId") ~ "}:{" ~ gopay.getConfig("clientSecret") ~ "}";
        Response response = gopay.call(
            "oauth2/token",
            GoPay.FORM,
            RequestMethods.post,
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

    static string[2] urls = ["https://gate.gopay.cz/", "https://gw.sandbox.gopay.com/"];

    private string[string] config;
    Duration timeout;

    public this(string[string] c, Duration d)
    {
        config = c;
        timeout = d;
    }

    public string getConfig(string key)
    {
        return this.config[key];
    }

    public auto call(string urlPath, string contentType, string method, string[string] data = null)
    {
        Request r;
        string url = this.buildUrl("api/" ~ urlPath);

        r.timeout = timeout;
        r.authenticator = new BasicAuthentication(this.config["clientId"], this.config["clientSecret"]);
        r.addHeaders(["Accept" : "application/json", "Accept-Language" : this.getAcceptedLanguage()]);
        if (method == this.FORM)
        {
            return r.execute(method, url, aa2params(data), contentType);
        }
        else
        {
            return r.execute(method, url, serializeToJsonString(data), contentType);
        }
    }

    public auto buildUrl(string urlPath)
    {
        auto isProductionMode = this.getConfig("isProductionMode");
        size_t index = 1;
        switch (isProductionMode)
        {
            case "1":
            case "t":
            case "true":
            case "T":
            case "True":
            case "TRUE":
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
