import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderInput;
import openfl.display.GraphicsShader;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.display.Shader;
import haxe.io.Bytes;
import openfl.display.ShaderParameter;
import haxe.Exception;
import sys.FileSystem;
import sys.io.File;
import flixel.system.FlxAssets.FlxShader;
import haxe.io.Path;
import openfl.display.DisplayObject;
import openfl.events.EventDispatcher;

using StringTools;


class Shader extends FlxShaderFix {
    public var shaderData(get, null):Dynamic;
    private function get_shaderData() {
        return __data;
    }

    public static var entireFuckingCustomVertexHeader:String =
  " attribute float openfl_Alpha;
    attribute vec4 openfl_ColorMultiplier;
    attribute vec4 openfl_ColorOffset;
    attribute vec4 openfl_Position;
    attribute vec2 openfl_TextureCoord;
    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;
    uniform mat4 openfl_Matrix;
    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    ";

    public static var entireFuckingCustomVertexBody:String = 
   "openfl_Alphav = openfl_Alpha;
    openfl_TextureCoordv = openfl_TextureCoord;
    if (openfl_HasColorTransform) {
        openfl_ColorMultiplierv = openfl_ColorMultiplier;
        openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
    }
    gl_Position = openfl_Matrix * openfl_Position;
    ";

    public static var entireFuckingCustomFragmentHeader:String = "
    
    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;
    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    uniform sampler2D bitmap;
    uniform bool hasTransform;
    uniform bool hasColorTransform;
    vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
    {
        vec4 color = texture2D(bitmap, coord);
        if (!hasTransform)
        {
            return color;
        }
        if (color.a == 0.0)
        {
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
        if (!hasColorTransform)
        {
            return color * openfl_Alphav;
        }
        color = vec4(color.rgb / color.a, color.a);
        mat4 colorMultiplier = mat4(0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
        color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
        if (color.a > 0.0)
        {
            return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        }
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    uniform vec4 _camSize;
    vec2 getCamPos(vec2 pos) {
        return (pos * openfl_TextureSize / vec2(_camSize.z, _camSize.w)) + vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z);
    }
    vec2 camToOg(vec2 pos) {
        return ((pos - vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z)) * vec2(_camSize.z, _camSize.w) / openfl_TextureSize);
    }
    vec4 textureCam(sampler2D bitmap, vec2 pos) {
        return texture2D(bitmap, camToOg(pos));
    }
    ";

    public static var entireFuckingCustomFragmentBody:String = "vec4 color = texture2D (bitmap, openfl_TextureCoordv);
    if (color.a == 0.0) {
        gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
    } else if (openfl_HasColorTransform) {
        color = vec4 (color.rgb / color.a, color.a);
        mat4 colorMultiplier = mat4 (0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = 1.0;
        color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
        if (color.a > 0.0) {
            gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        } else {
            gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
        }
    } else {
        gl_FragColor = color * openfl_Alphav;
    }
    ";

    public function new(fragCode:String, vertCode:String) {
        this.glFragmentSource = fragCode.replace("#pragma body", entireFuckingCustomFragmentBody).replace("#pragma header", entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");
        this.glVertexSource = vertCode.replace("#pragma body", entireFuckingCustomVertexBody).replace("#pragma header", entireFuckingCustomVertexHeader);
        super();
    }

    public static function create(cShader:String) {
        var fragPath = 'assets/shaders/' + cShader + '.frag';
        var vertPath = 'assets/shaders/' + cShader + '.vert'; 

        var fragExists:Bool = true;
        var vertExists:Bool = true;
        fragExists = FNFAssets.exists(fragPath);
        vertExists = FNFAssets.exists(vertPath);
        if (!(fragExists || vertExists)) {
            throw new Exception("Shader not found.");
        }
        return new Shader(FNFAssets.getText(fragPath), FNFAssets.getText(vertPath));
    }

    public function setValue(name:String, value:Dynamic) {
        
        if (Reflect.getProperty(data, name) != null) {
            var d:ShaderParameter<Dynamic> = Reflect.getProperty(data, name);
            Reflect.setProperty(d, "value", [value]);
        }
    }

    public function setValues(values:Map<String, Any>) {
        if (values == null) return;
        
        var kInt = values.keys();
        while(kInt.hasNext()) {
            var key = kInt.next();
            Reflect.setProperty(Reflect.getProperty(data, key), "value", [values[key]]);
        }
    }

    @:noCompletion private override function __processGLData(source:String, storageType:String):Void
    {
        var lastMatch = 0, position, regex, name, type;

        if (storageType == "uniform")
        {
            regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
        }
        else
        {
            regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
        }

        while (regex.matchSub(source, lastMatch))
        {
            type = regex.matched(1);
            name = regex.matched(2);

            if (StringTools.startsWith(name, "gl_"))
            {
                continue;
            }

            var isUniform = (storageType == "uniform");

            if (StringTools.startsWith(type, "sampler"))
            {
                var input = new ShaderInput<BitmapData>();
                input.name = name;
                @:privateAccess
                input.__isUniform = isUniform;
                __inputBitmapData.push(input);

                switch (name)
                {
                    case "openfl_Texture":
                        __texture = input;
                    case "bitmap":
                        __bitmap = input;
                    default:
                }


                Reflect.setField(__data, name, input);
                if (__isGenerated) {
                    try {Reflect.setField(this, name, input);} catch(e) {}
                }
            }
            else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null)
            {
                var parameterType:ShaderParameterType = switch (type)
                {
                    case "bool": BOOL;
                    case "double", "float": FLOAT;
                    case "int", "uint": INT;
                    case "bvec2": BOOL2;
                    case "bvec3": BOOL3;
                    case "bvec4": BOOL4;
                    case "ivec2", "uvec2": INT2;
                    case "ivec3", "uvec3": INT3;
                    case "ivec4", "uvec4": INT4;
                    case "vec2", "dvec2": FLOAT2;
                    case "vec3", "dvec3": FLOAT3;
                    case "vec4", "dvec4": FLOAT4;
                    case "mat2", "mat2x2": MATRIX2X2;
                    case "mat2x3": MATRIX2X3;
                    case "mat2x4": MATRIX2X4;
                    case "mat3x2": MATRIX3X2;
                    case "mat3", "mat3x3": MATRIX3X3;
                    case "mat3x4": MATRIX3X4;
                    case "mat4x2": MATRIX4X2;
                    case "mat4x3": MATRIX4X3;
                    case "mat4", "mat4x4": MATRIX4X4;
                    default: null;
                }

                var length = switch (parameterType)
                {
                    case BOOL2, INT2, FLOAT2: 2;
                    case BOOL3, INT3, FLOAT3: 3;
                    case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
                    case MATRIX3X3: 9;
                    case MATRIX4X4: 16;
                    default: 1;
                }

                var arrayLength = switch (parameterType)
                {
                    case MATRIX2X2: 2;
                    case MATRIX3X3: 3;
                    case MATRIX4X4: 4;
                    default: 1;
                }

                switch (parameterType)
                {
                    case BOOL, BOOL2, BOOL3, BOOL4:
                        var parameter = new ShaderParameter<Bool>();
                        @:privateAccess
                        parameter.name = name;
                        @:privateAccess
                        parameter.type = parameterType;
                        @:privateAccess
                        parameter.__arrayLength = arrayLength;
                        @:privateAccess
                        parameter.__isBool = true;
                        @:privateAccess
                        parameter.__isUniform = isUniform;
                        @:privateAccess
                        parameter.__length = length;
                        __paramBool.push(parameter);

                        if (name == "openfl_HasColorTransform")
                        {
                            __hasColorTransform = parameter;
                        }

                        Reflect.setField(__data, name, parameter);
                        if (__isGenerated) {
                            try {Reflect.setField(this, name, parameter);} catch(e) {}
                        }

                    case INT, INT2, INT3, INT4:
                        var parameter = new ShaderParameter<Int>();
                        @:privateAccess
                        parameter.name = name;
                        @:privateAccess
                        parameter.type = parameterType;
                        @:privateAccess
                        parameter.__arrayLength = arrayLength;
                        @:privateAccess
                        parameter.__isBool = true;
                        @:privateAccess
                        parameter.__isUniform = isUniform;
                        @:privateAccess
                        parameter.__length = length;
                        __paramInt.push(parameter);
                        Reflect.setField(__data, name, parameter);
                        if (__isGenerated) {
                            try {Reflect.setField(this, name, parameter);} catch(e) {}
                        }

                    default:
                        var parameter = new ShaderParameter<Float>();
                        @:privateAccess
                        parameter.name = name;
                        @:privateAccess
                        parameter.type = parameterType;
                        @:privateAccess
                        parameter.__arrayLength = arrayLength;
                        #if lime
                        @:privateAccess
                        if (arrayLength > 0) parameter.__uniformMatrix = new openfl.utils._internal.Float32Array(arrayLength * arrayLength);
                        #end
                        @:privateAccess
                        parameter.__isFloat = true;
                        @:privateAccess
                        parameter.__isUniform = isUniform;
                        @:privateAccess
                        parameter.__length = length;
                        __paramFloat.push(parameter);

                        if (StringTools.startsWith(name, "openfl_"))
                        {
                            switch (name)
                            {
                                case "openfl_Alpha": __alpha = parameter;
                                case "openfl_ColorMultiplier": __colorMultiplier = parameter;
                                case "openfl_ColorOffset": __colorOffset = parameter;
                                case "openfl_Matrix": __matrix = parameter;
                                case "openfl_Position": __position = parameter;
                                case "openfl_TextureCoord": __textureCoord = parameter;
                                case "openfl_TextureSize": __textureSize = parameter;
                                default:
                            }
                        }

                        Reflect.setField(__data, name, parameter);
                        if (__isGenerated) {
                            try {Reflect.setField(this, name, parameter);} catch(e) {}
                        }

                        
                }
            }

            position = regex.matchedPos();
            lastMatch = position.pos + position.len;
        }
    }
}

class ShaderCustom extends Shader {
	
    public function setCamSize(x:Float, y:Float, width:Float, height:Float) {
        data._camSize.value = [x, y, width, height];
    }

    public function init(fragCode:String, vertCode:String) {

    }
    public function new(cShader:String /*, values:Map<String, Any>*/ ) {
        //var mPath = Paths.modsPath;

        var fragPath = "assets/shaders/" + cShader + ".frag";
        var vertPath = "assets/shaders/" + cShader + ".vert";

        var glVertexSource = "#pragma header
        attribute float alpha;
        attribute vec4 colorMultiplier;
        attribute vec4 colorOffset;
        uniform bool hasColorTransform;
        
        void main(void)
        {
            openfl_Alphav = openfl_Alpha;
            openfl_TextureCoordv = openfl_TextureCoord;
            if (openfl_HasColorTransform) {
                    openfl_ColorMultiplierv = openfl_ColorMultiplier;
                    openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
            }
            gl_Position = openfl_Matrix * openfl_Position;
            openfl_Alphav = openfl_Alpha * alpha;
            if (hasColorTransform)
            {
                    openfl_ColorOffsetv = colorOffset / 255.0;
                    openfl_ColorMultiplierv = colorMultiplier;
            }
        }".replace("#pragma body", Shader.entireFuckingCustomVertexBody).replace("#pragma header", Shader.entireFuckingCustomVertexHeader);

        var glFragmentSource = "
        #pragma header
    
        void main(void)
        {
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        }".replace("#pragma body", Shader.entireFuckingCustomFragmentBody).replace("#pragma header", Shader.entireFuckingCustomFragmentHeader).replace(" attribute ", " uniform ");

        if (fragPath.trim() != "" && FNFAssets.exists(fragPath))
            glFragmentSource = FNFAssets.getText(fragPath);
        
        if (vertPath.trim() != "" && FNFAssets.exists(vertPath)) {
            var vert = FNFAssets.getText(vertPath);
            glVertexSource = vert;
        }

        super(glFragmentSource, glVertexSource);
    }
}