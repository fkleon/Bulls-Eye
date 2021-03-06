part of softhai.bulls_eye.Server;

typedef void HandleRoutingException(HttpRequestException ex);

abstract class Route {
  
  common.RouteDef _routeDefenition;
  List<String> _methods;
  List<String> _contentTypes;
  List<HandleRoutingException> _handleRoutingException = new List<HandleRoutingException>();
  
  Route(this._routeDefenition, [this._methods, this._contentTypes]);
  
  // Exception Handling
  void registerExceptionHandler(HandleRoutingException handler)
  {
    this._handleRoutingException.add(handler);
  }
  
  void _handleException(HttpRequestException ex)
  {
    for(var handler in this._handleRoutingException){
      handler(ex);
    }
  }
  
  // Route match the path
  bool match(HttpRequest request) {

    // Check request method if required
    if(this._methods != null)
    {
      if(!this._methods.contains(request.method)) 
      {
        return false;
      }
    }
    
    // Check requested content type if required
    if(this._contentTypes != null)
    {
      if(!request.headers[HttpHeaders.ACCEPT].contains("*/*")) // All Allowed?
      {
        var possibleContentTypes = this._contentTypes.where((ct) => request.headers[HttpHeaders.ACCEPT].firstWhere((data) => data.toString().contains(ct), orElse: () => null) != null);
        if(possibleContentTypes.length == 0) // Matches any ContentType
        {
          return false;
        }
      }
    }
    
    // Check Route
    return this._routeDefenition.matcher.match(request.uri.path);
  }
  
  // Executer
  bool execute(HttpRequest request) 
  {
    var variables = this._routeDefenition.matcher.getMatches(request.uri.path);
    var context = new RouteContext(request, this._routeDefenition, variables);
    return this._internalExecute(context);
  }
  
  bool _internalExecute(RouteContext context);
  
  String toString() {
    return this._routeDefenition.name;
  }
}

class RouteContext {

  HttpRequest request;
  common.RouteDef currentRoute;
  common.UriMatcherResult variables;
  Map<String, Object> contextData;

  RouteContext(this.request, this.currentRoute, this.variables) {
    this.contextData = new Map<String,Object>();
  }
}
