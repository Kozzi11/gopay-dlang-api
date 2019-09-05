module gopay.definition.request;

enum RequestMethods : string
{
    // RFC7231
    get = "GET",
    het = "HEAD",
    post = "POST",
    put = "PUT",
    delete_ = "DELETE",
    connect = "CONNECT",
    options = "OPTIONS",
    trace = "TRACE",
}