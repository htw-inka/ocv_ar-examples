//
//  CCEffect.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import "CCEffect.h"
#import "CCEffect_Private.h"
#import "CCtexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
static NSString* fragBase =
@"%@\n\n"   // uniforms
@"%@\n"     // varying vars
@"%@\n"     // function defs
@"void main() {\n"
@"gl_FragColor = %@;\n"
@"}\n";

static NSString* vertBase =
@"%@\n\n"   // uniforms
@"%@\n"     // varying vars
@"%@\n"     // function defs
@"void main(){\n"
@"	cc_FragColor = cc_Color;\n"
@"	cc_FragTexCoord1 = cc_TexCoord1;\n"
@"	cc_FragTexCoord2 = cc_TexCoord2;\n"
@"	gl_Position = %@;\n"
@"}\n";

#pragma mark CCEffectFunction

@implementation CCEffectFunction

-(id)initWithName:(NSString *)name body:(NSString*)body returnType:(NSString *)returnType
{
    if((self = [super init]))
    {
        _body = [body copy];
        _name = [name copy];
        _returnType = [returnType copy];
        return self;
    }
    
    return self;
}

+(id)functionWithName:(NSString*)name body:(NSString*)body returnType:(NSString*)returnType
{
    return [[self alloc] initWithName:name body:body returnType:returnType];
}

-(NSString*)function
{
    NSString* function = [NSString stringWithFormat:@"%@ %@(void)\n{\n%@\n}", _returnType, _name, _body];
    return function;
}

-(NSString*)method
{
    NSString* method = [NSString stringWithFormat:@"%@()", _name];
    return method;
}

@end

#pragma mark CCEffectUniform

@implementation CCEffectUniform

-(id)initWithType:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    if((self = [super init]))
    {
        _name = [name copy];
        _type = [type copy];
        _value = value;
        
        return self;
    }
    
    return self;
}

+(id)uniform:(NSString*)type name:(NSString*)name value:(NSValue*)value
{
    return [[self alloc] initWithType:type name:name value:value];
}

-(NSString*)declaration
{
    NSString* declaration = [NSString stringWithFormat:@"uniform %@ %@;", _type, _name];
    return declaration;
}

@end

#pragma mark CCEffectVarying

@implementation CCEffectVarying

-(id)initWithType:(NSString*)type name:(NSString*)name
{
    if((self = [super init]))
    {
        _name = [name copy];
        _type = [type copy];
        
        return self;
    }
    
    return self;
}

+(id)varying:(NSString*)type name:(NSString*)name
{
    return [[self alloc] initWithType:type name:name];
}

-(NSString*)declaration
{
    NSString* declaration = [NSString stringWithFormat:@"varying %@ %@;", _type, _name];
    return declaration;
}

@end

#pragma mark CCEffectRenderPass

@implementation CCEffectRenderPass

//

@end

#pragma mark CCEffect

@implementation CCEffect

+ (NSArray *)defaultEffectFragmentUniforms
{
    return @[
             [CCEffectUniform uniform:@"sampler2D" name:@"cc_PreviousPassTexture" value:(NSValue *)[CCTexture none]]
            ];
}

+ (NSArray *)defaultEffectVertexUniforms
{
    return @[];
}

-(id)init
{
    if((self = [super init]))
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] copy];
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] copy];
        _fragmentFunctions = [[NSMutableArray alloc] init];
        _vertexFunctions = [[NSMutableArray alloc] init];
        
        [self buildFragmentFunctions];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying
{
    if((self = [super init]))
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] arrayByAddingObjectsFromArray:fragmentUniforms];
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] arrayByAddingObjectsFromArray:vertexUniforms];
        _varyingVars = [varying copy];
        _fragmentFunctions = [[NSMutableArray alloc] init];
        _vertexFunctions = [[NSMutableArray alloc] init];
        
        [self buildShaderUniforms:_fragmentUniforms vertexUniforms:_vertexUniforms];
        [self buildFragmentFunctions];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying
{
    if((self = [super init]))
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] arrayByAddingObjectsFromArray:fragmentUniforms];
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] arrayByAddingObjectsFromArray:vertexUniforms];
        _fragmentFunctions = fragmentFunctions;
        _varyingVars = [varying copy];
        [self buildShaderUniforms:_fragmentUniforms vertexUniforms:_vertexUniforms];
        [self buildVertexFunctions];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(id)initWithFragmentFunction:(NSMutableArray*) fragmentFunctions vertexFunctions:(NSMutableArray*)vertextFunctions fragmentUniforms:(NSArray*)fragmentUniforms vertextUniforms:(NSArray*)vertexUniforms varying:(NSArray*)varying
{
    if((self = [super init]))
    {
        _fragmentUniforms = [[CCEffect defaultEffectFragmentUniforms] arrayByAddingObjectsFromArray:fragmentUniforms];
        _vertexUniforms = [[CCEffect defaultEffectVertexUniforms] arrayByAddingObjectsFromArray:vertexUniforms];
        _fragmentFunctions = fragmentFunctions;
        _vertexFunctions = vertextFunctions;
        _varyingVars = [varying copy];
        [self buildShaderUniforms:_fragmentUniforms vertexUniforms:_vertexUniforms];
        [self buildEffectShader];
        
        return self;
    }
    
    return self;
}

-(void)buildShaderUniforms:(NSArray*)fragmentUniforms vertexUniforms:(NSArray*)vertexUniforms
{
    [_shaderUniforms removeAllObjects];
    
    for(CCEffectUniform* uniform in fragmentUniforms)
    {
        if(_shaderUniforms == nil)
            _shaderUniforms = [[NSMutableDictionary alloc] init];
        
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
    
    for(CCEffectUniform* uniform in vertexUniforms)
    {
        if(_shaderUniforms == nil)
            _shaderUniforms = [[NSMutableDictionary alloc] init];
        
        [_shaderUniforms setObject:uniform.value forKey:uniform.name];
    }
}

-(void)buildEffectShader
{
    if(_shader != nil)
        return;
    
    //Build varying vars
    NSMutableString* varyingVarsToInsert = [[NSMutableString alloc] init];
    for(CCEffectUniform* varying in _varyingVars)
    {
        [varyingVarsToInsert appendFormat:@"%@\n", varying.declaration];
    }

    
    // Build fragment body
    NSMutableString* fragUniforms = [[NSMutableString alloc] init];
    for(CCEffectUniform* uniform in _fragmentUniforms)
    {
        [fragUniforms appendFormat:@"%@\n", uniform.declaration];
    }
    
    NSMutableString* fragFunctions = [[NSMutableString alloc] init];
    NSMutableString* effectFunctionBody = [[NSMutableString alloc] init];
    [effectFunctionBody appendString:@"return "];
    
    for(CCEffectFunction* curFunction in _fragmentFunctions)
    {
        [fragFunctions appendFormat:@"%@\n", curFunction.function];
        
        [effectFunctionBody appendString:curFunction.method];
        if([_fragmentFunctions lastObject] != curFunction)
            [effectFunctionBody appendString:@" + "];
        else
            [effectFunctionBody appendString:@";"];
    }
    
    CCEffectFunction* effectFunction = [[CCEffectFunction alloc] initWithName:@"effectFunction" body:effectFunctionBody returnType:@"vec4"];
    [fragFunctions appendFormat:@"%@\n", effectFunction.function];
    
    NSString* fragBody = [NSString stringWithFormat:fragBase, fragUniforms, varyingVarsToInsert, fragFunctions, effectFunction.method];
    //NSLog(@"\n------------fragBody:\n%@", fragBody);
    
    
    // Build vertex body
    NSMutableString* vertexUniforms = [[NSMutableString alloc] init];
    for(CCEffectUniform* uniform in _vertexUniforms)
    {
        [vertexUniforms appendFormat:@"%@\n", uniform.declaration];
    }

    
    NSMutableString* vertexFunctions = [[NSMutableString alloc] init];
    effectFunctionBody = [[NSMutableString alloc] init];
    [effectFunctionBody appendString:@"return "];
    
    for(CCEffectFunction* curFunction in _vertexFunctions)
    {
        [vertexFunctions appendFormat:@"%@\n", curFunction.function];
        
        [effectFunctionBody appendString:curFunction.method];
        if([_vertexFunctions lastObject] != curFunction)
            [effectFunctionBody appendString:@" + "];
        else
            [effectFunctionBody appendString:@";"];
    }
    
    effectFunction = [[CCEffectFunction alloc] initWithName:@"effectFunction" body:effectFunctionBody returnType:@"vec4"];
    [vertexFunctions appendFormat:@"%@\n", effectFunction.function];
    
    NSString* vertBody = [NSString stringWithFormat:vertBase, vertexUniforms, varyingVarsToInsert, vertexFunctions, effectFunction.method];
    //NSLog(@"\n------------vertBody:\n%@", vertBody);
    
    _shader = [[CCShader alloc] initWithVertexShaderSource:vertBody fragmentShaderSource:fragBody];

}

-(void)buildFragmentFunctions
{
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_FragColor;" returnType:@"vec4"];
    [_fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"defaultEffect" body:@"return cc_Position;" returnType:@"vec4"];
    [_vertexFunctions addObject:vertexFunction];
}

-(void)renderPassBegin:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

-(void)renderPassEnd:(CCEffectRenderPass*) renderPass defaultBlock:(void (^)())defaultBlock
{
    if(defaultBlock)
        defaultBlock();
}

-(NSInteger)renderPassesRequired
{
    return 1;
}

@end
#endif



