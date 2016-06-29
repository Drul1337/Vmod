////////////////////////////////////////////////////////////////////////////////
//  vmodStaticUtilities
//
//  Global utility functions.
////////////////////////////////////////////////////////////////////////////////
class vmodStaticUtilities extends Object abstract;

////////////////////////////////////////////////////////////////////////////////
//  Interpolation functions
//  t: Current time
//  b: Starting value
//  e: End value
//  d: Duration
static function float InterpLinear(float t, float b, float e, float d)
{
    if(t <= 0.0)    return b;
    if(t >= d)      return e;
    t = t / d;
    return ((1.0 - t) * b) + (t * e);
}

static function float InterpQuadratic(float t, float b, float e, float d)
{
    local float c;
    c = e - b;
    
    if(t <= 0.0)    return b;
    if (t >= d)     return e;
    t = t / d;
    return c * t * t + b;
}