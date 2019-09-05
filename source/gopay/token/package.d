module gopay.token;

import gopay.http;
public import std.datetime.systime;
public import core.time;

class AccessToken
{
    SysTime expirationDate;

    string token = "";

    Response response;

    @property bool isExpired()
    {
        return token.length == 0 || expirationDate < Clock.currTime;
    }
}

interface TokenCache
{
    void setAccessToken(string client, AccessToken t);

    AccessToken getAccessToken(string client);
}

class InMemoryTokenCache : TokenCache
{
    private AccessToken[string] tokens;

    void setAccessToken(string client, AccessToken t)
    {
        tokens[client] = t;
    }

    public AccessToken getAccessToken(string client)
    {
        return tokens.get(client, null);
    }
}