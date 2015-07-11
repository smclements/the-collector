Class = require "util.hump.class"
Signals = require "util.hump.signal" 
require "components.gameObjects"
require "components.background"
require "components.bullet"
require "components.bulletColl"
require "components.player"

require "util.audio"
anim8 = require "util.anim8"
require "components.bloom"

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end --enable debugging in zerobrane studio
         
    spritesheet = love.graphics.newImage("assets/image/character.png")
    player = Player(400,450,spritesheet,125,125,50)
        
    Components = GameObjects()
    Components:register("background",Background())
    Components:register("bulletColl",BulletColl())
    Components:register("player",player)
        
    love.graphics.setBackgroundColor(80,85,82)	
   
	sound = love.audio.newSource("assets/sound/insects.ogg","stream")
	sound:setLooping(true)
	love.audio.setVolume(0.05)

	bulletsRemoved = 0
	currentIndices = "not set"
    soundOn = false
    
    bloom = CreateBloomEffect(400,300)
    
    canvas = love.graphics.newCanvas(800,600)
    backgroundCanvas = love.graphics.newCanvas(800,600)
    love.graphics.setBlendMode('alpha')
end

function love.update(dt)
    Components:update(dt)
end

function love.draw()
	--love.graphics.setShader(distortion)
    --love.graphics.setShader(glow)
    --love.graphics.setShader()
    
    --bloom:predraw()
    --bloom:enabledrawtobloom()

love.graphics.setCanvas(canvas)
canvas:clear()
    Components:draw()
love.graphics.setCanvas()

--bloom:predraw()
--bloom:enabledrawtobloom()

love.graphics.draw(canvas)

--bloom:postdraw()
    --love.graphics.setShader()
        
	--love.graphics.setColor(255,255,255)
	love.graphics.setColor(255,255,255)
	love.graphics.print( string.format("fps : %s", love.timer.getFPS( ) ), 10, 20 )	
	love.graphics.print( string.format("bullets removed : %s", bulletsRemoved ), 10, 40 )
	love.graphics.print( string.format("[s]ound is %s", soundOn and "on" or "off" ), 10, 60 )
end

function love.mousepressed(x, y, button)
    if button == "l" then
        Signals.emit('fireNet', x, y, player.spritewidth, player.spriteheight, player.x, player.y)
    end
end

function love.keyreleased(key)
    if key == "s" then
        soundOn = not soundOn
      
        if soundOn then
            love.audio.play(sound)
        else
            love.audio.stop(sound)
        end
    end
end

spotlight = love.graphics.newShader([[
extern float time;

vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
               dot(p,vec2(269.5,183.3)), 
               dot(p,vec2(419.2,371.9)) );
   return fract(sin(q)*43758.5453);
}

vec4 effect(vec4 vcolor, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
  vec2 size = vec2(800.0, 600.0); // screen size
  vec2 scaledSize = size/10.0;
   vec2 x = scaledSize * texture_coords;
  
  float u = 0.375*sin(time/2); // amount of 'voronoiification'
  vec2 p = floor(x);
  vec2 f = fract(x);
      
   float k = 64.0;
  
  float va = 0.0;
   float wt = 0.0;
    for( int j=-2; j<=2; j++ )
        for( int i=-2; i<=2; i++ )
        {
            vec2 g = vec2( (i+0.5),(j+0.5) );
            vec3 o = hash3( p + g )*vec3(u,u,1.0);
            vec2 r = g - f + o.xy;
            float d = dot(r,r);
            float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
            va += o.z*ww;
            wt += ww;
        }
   
  float c = va/wt;
   
  vec4 txl = Texel(texture, texture_coords);
   
  
   return vec4( c, c, c, 1.0 ) * txl;
}
]])

distortion = love.graphics.newShader([[
extern number exposure = 0.5;
extern number decay = 0.95;
extern number density = 0.2;
extern number weight = 0.31;
extern vec2 lightPositionOnScreen= vec2(0.50,0.3);
extern number NUM_SAMPLES = 60.0 ;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec2 deltaTextCoord = vec2( texture_coords - lightPositionOnScreen.xy );
	vec2 textCoo = texture_coords.xy;
	deltaTextCoord *= 1.0 / float(NUM_SAMPLES) * density;
	float illuminationDecay = 1.0;
	vec4 cc = vec4(0.0, 0.0, 0.0, 1.0);

	for(int i=0; i < NUM_SAMPLES ; i++)
	{
		textCoo -= deltaTextCoord;
		vec4 sample = Texel( texture, textCoo );
		sample *= illuminationDecay * weight;
		cc += sample;
		illuminationDecay *= decay;
	}
	cc *= exposure;
	return cc;
}
]])

glow = love.graphics.newShader([[
extern vec2 size;
extern int samples = 2; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 1.5; // lower = smaller glow, better quality
 
vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;
  
  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(tex, tc + offset);
    }
  }
  
  return ((sum / (samples * samples)) + source) * colour;
  }
]])

