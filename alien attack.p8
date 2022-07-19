pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- variables
enemies={}
alies={}
items={}
enemynum=0
alienum=0
frame30persec=0
level=0
over=0
score=0
minenum=35
maxlevels=3
maxalies=600
gdamage=0.2
tys={"dark","cor"}
pal(14,0,0)
function keypress()
 -- a very helpful comment. you're welcome.
 return stat(31)
end
function gameover()
 -- gameover triggers defeat
 over=1
end
function clearlevel()
 -- clear level removes all enemies and tiles.
 enemies={}
 enemynum=0
end
function complete()
 -- complete kills all enemies and starts a new wave.
 enemies={}
 enemynum=0
 score+=1
 level=flr(rnd(maxlevels))+1
 frame30persec=0
 fs=0
end
function newwave()
 -- new wave keep all enemies on screen and starts a new wave.
 level=flr(rnd(maxlevels))+1
 frame30persec=0
 fs=0
end
function clearalies()
 -- reset alie counts
 alies={}
 alienum=0
 minenum=35
end
function _draw()
 -- clears the screen
 cls()
 -- draw enemies ,alies ,and items.
 for a in all(alies) do
  spr(a.entspr,a.x,a.y)
 end
 if enemynum > 0 then
  for e in all(enemies) do
   spr(e.espr,e.x,e.y,e.w,e.h)
  end
 end
 for i in all(items) do
  spr(i.ispr,i.ix,i.iy)
 end
 if over == 1 then
  print("game over!",0,0,10)
  print("the aliens toke over!",0,8,10)
  print("you survived "..score.." waves!",0,16,11)
 elseif level == 0 then
  print("❎ or x to start",0,0,11)
 elseif over == 0 and level != 0 then
  print("wave "..score,0,0,11)
  print("mines left: "..minenum,0,8,11)
 end
 spr(103,stat(32)-3,stat(33)-3)
end

function hitbox(entx,enty,w,h,cox,coy)
 local r=0
 if cox > entx then
  if cox < entx+w then
   if coy > enty then
    if coy < enty+h then
     return true
    else
     r=1
    end
   else
    r=1
   end
  else
   r=1
  end
 else
  r=1
 end
 if r==1 then
  return false
 end 
end

function addenemy(es,ew,eh,ex,ey,ehp,etype,entspr)
 add(enemies,{enemyc=10,wait=30,etime=0,s=es,w=ew,h=eh,espr=entspr,x=ex,y=ey,hp=ehp,entype=etype})
 enemynum+=1
end

function additem(pispr,pix,piy,pixs,piys)
 add(items,{ispr=pispr,ix=pix,iy=piy,xs=pixs,ys=piys})
end

function addalie(atype,ahp,ax,ay,aspr,as,ammowait)
 if alienum < maxalies then
 add(alies,{etype=atype,hp=ahp,etype=atype,x=ax,y=ay,entspr=aspr,s=as,wait=ammowait})
 alienum+=1
 end
end

function _update()
 -- enable devkit mode
 poke(0x5f2d, 1)
 key=keypress()
 -- crash sequence
 if alienum > maxalies then
  run()
 end
 -- 1 frame pass
 frame30persec+=1
 fs=frame30persec
 -- spawn lazer gunner
 if key == "q" and alienum < maxalies then
  addalie("lazer alie",8,stat(32)-3,stat(33)-3,32,0,0)
 end
 if key == "r" and alienum < maxalies then
  addalie("machine lazer",8,stat(32)-3,stat(33)-3,48,0,0)
 end
 if key == "|" then
  addenemy(0.2,2,2,stat(32)-3,stat(33),1,"mother ship",106)
 end
 if key == [[\]] then
  addenemy(0,2,2,stat(32)-3,stat(33),1,"annom",96)
  enemynum-=1
 end
 if minenum > 0 and btnp(🅾️) and alienum < maxalies then
  addalie("mine",0,stat(32)-3,stat(33)-3,42,0)
  if level != 0 then
   minenum-=1
  end
 end
 if stat(34) == 1 then
  sfx(2)
 end
 if stat(34) == 2 and level > 0 then
  gameover()
  maxlevels=3
  addenemy(0.2,2,2,16*8,0,1,"mother ship",106)
 end
 -- item ai's
 for iv in all(items) do
  iv.ix+=iv.xs
  iv.iy+=iv.ys
  if iv.ispr == 45 then
   iv.ispr=31
  elseif iv.ispr == 31 then
   iv.ispr=45
  end
  if hitbox(iv.ix,iv.iy,8,8,stat(32),stat(33)) and iv.ispr == 45 or hitbox(iv.ix,iv.iy,8,8,stat(32),stat(33)) and iv.ispr == 31 then
   gdamage+=0.2
   del(items,iv)
  end
 end
 -- alie ai's
 for a in all(alies) do
  a.x-=a.s
  if a.etype == "lazer alie" then
   if alienum < maxalies then
    a.wait+=1
   end
   if a.wait > 26 and alienum < maxalies then
    addalie("lazer",0,a.x,a.y+4,16,-0.9,0)
    a.wait=-8
   end
  end
  if a.etype == "machine lazer" then
   if alienum < maxalies then
    a.wait+=1
   end
   if a.wait > 26 and alienum < maxalies then
    addalie("lazer",0,a.x,a.y+4,16,-0.9,0)
    addalie("lazer",0,a.x-1,a.y+4,16,-0.9,0)
    addalie("lazer",0,a.x-2,a.y+4,16,-0.9,0)
    addalie("lazer",0,a.x+1,a.y+4,16,-0.9,0)
    addalie("lazer",0,a.x+2,a.y+4,16,-0.9,0)
    a.wait=10
   end
  end
  if a.etype == "lazer" then
   if a.x > 21*8 then
    del(alies,a)
    alienum-=1
   end
  end
 end
 for e in all(enemies) do
  for a in all(alies) do
   -- enemy attack ai's
   if hitbox(e.x,e.y,e.w*8,e.h*8,a.x+8,a.y+4) then
    if a.etype == "mine" then
     e.hp-=15
     del(alies,a)
     alienum-=1
    end
    if a.etype == "lazer" then
     e.hp-=gdamage
     del(alies,a)
     alienum-=1
    end
    if a.etype == "lazer alie" then
     a.hp-=1
     e.x+=e.s
     if e.w > 2 and e.h > 2 then
      a.hp=0
     end
    end
    if a.etype != "mine" and a.hp < 1 then
     del(alies,a)
     alienum-=1
    end
    if e.entype == "lazer field" then
     del(alies,a)
     a.hhp-=3
     del(enemies,e)
     enemynum-=1
    end
   end
  end
 end
 if enemynum > 0 then
  for e in all(enemies) do
   -- enemy ai's
   e.x-=e.s
   if e.x < -16 and over == 0 and level > 0 then
    gameover()
    maxlevels=3
    addenemy(0.2,2,2,16*8,0,1,"mother ship",106)
   end
   if e.x < -16 and over == 1 and e.entype == "mother ship" then
    clearlevel()
    level=0
    score=1
    over=0
    clearalies()
   end
   if e.x < 0 and over == 0 and e.entype == "mother ship" then
    e.x=0
   end
   if stat(34) == 1 and hitbox(e.x,e.y,e.w*8,e.h*8,stat(32),stat(33)) == true then
    e.hp-=gdamage
   end
   if e.entype == "ufo" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     if e.enemyc>0 then
      addenemy(0.4,1,1,e.x,e.y+7,2,"alien",1)
      e.etime=0
      e.wait+=2
      e.enemyc-=1
      sfx(0)
     else
      e.s= -0.1
     end
    end
   end
   if e.entype == "yeti ufo" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     if e.enemyc>0 then
      addenemy(0.9,1,1,e.x,e.y+7,40,"yeti",43)
      e.etime=0
      e.wait+=2
      e.enemyc-=1
      sfx(0)
     else
      e.s= 0.8
     end
    end
   end
   if e.entype == "yeti iufo" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     addenemy(0.9,1,1,e.x,e.y+7,40,"yeti",43)
     e.etime=0
     e.wait+=2
     e.enemyc-=1
     sfx(0)
    end
   end
   if e.entype == "iufo" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     if e.enemyc>0 then
      addenemy(0.4,1,1,e.x,e.y+7,2,"alien",1)
      e.etime=0
      e.wait+=2
      sfx(0)
     end
    end
   end
   if e.entype == "hackiufo" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     if e.enemyc>0 then
      addenemy(e.s+0.1,2,2,e.x,e.y,2,"giga-alien",76)
      e.etime=0
      e.wait+=2
      e.s-=0.1
      sfx(0)
     end
    end
   end
   if e.entype == "aliengen" or e.entype == "dark alien" then -- alien death
    e.etime+=1
    if e.etime>e.wait then
     if e.enemyc>0 then
      addenemy(0.4,1,1,e.x,e.y+7,2,"alien",1)
      e.etime=0
      e.wait+=2
      sfx(1)
     end
    end
   end
   if e.entype == "annom" then -- annom
    e.etime+=1
    if e.dietime == nil then
     e.dietime=0
    end
    e.dietime+=1
    if e.dietime >= 800 then
     del(enemies,e)
     sfx(4)
    end
    if e.etime>80 then
     if e.enemyc>0 then
      rhnd=flr(rnd(9))
      rh=1
      e.etime=0
  				if rhnd == 0 then rh=0 addenemy(0.8,1,1,e.x,e.y+7,2,"coronovirus alien",70) 
  				elseif rhnd == 8 then rh=0 addenemy(0.1,2,2,e.x,e.y,80,"coronovirus giga-alien",71) 
  				end
      if rh == 0 then
      e.etime=0
      e.wait+=2
      sfx(3)
      end
     end
    end
   end
   if e.entype == "yeti alien" then -- alien death
    e.etime+=1
    if e.x < 4*8 then
     e.s= -0.8
    end
   end
   if e.hp < 1 then
    -- daytime aliens
    if e.entype == "alien" or e.entype == "dark alien" then -- alien death
     if rnd(8) > 6 then
      additem(45,e.x,e.y,-0.2,0)
     end
     del(enemies,e)
     enemynum-=1
    elseif e.entype == "armored alien" or e.entype == "protected alien" then
     e.entype="alien"
     e.espr=1
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "protected armored alien" then
     e.entype="armored alien"
     e.espr=2
     e.w=1
     e.h=1
     e.hp=10
    elseif e.entype == "protected shield alien" then
     e.entype="shield alien"
     e.espr=3
     e.w=1
     e.h=1
     e.hp=40
    elseif e.entype == "shield alien" then
     e.entype="alien"
     e.espr=1
     e.w=1
     e.h=1
     e.hp=2
     -- night time aliens
    elseif e.entype == "dark shield alien" then
     e.entype="dark alien"
     e.espr=33
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "dark armored alien" then
     e.entype="dark alien"
     e.espr=33
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "glow alien" then
     e.entype="dark alien"
     e.espr=33
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "glow armored alien" then
     e.entype="dark armored alien"
     e.espr=33
     e.w=1
     e.h=1
     e.hp=10
    elseif e.entype == "glow shield alien" then
     e.entype="dark shield alien"
     e.espr=35
     e.w=1
     e.h=1
     e.hp=5
    elseif e.entype == "glow armored giga-alien" then
     e.entype="dark armored giga-alien"
     e.espr=38
     e.w=2
     e.h=2
     e.hp=30
    elseif e.entype == "dark armored giga-alien" then
     e.entype="dark shield giga-alien"
     e.espr=40
     e.w=2
     e.h=2
     e.hp=10
    elseif e.entype == "dark shield giga-alien" then
     e.entype="dark giga-alien"
     e.espr=64
     e.w=2
     e.h=2
     e.hp=30
    elseif e.entype == "protected armored giga-alien" then
     e.entype="armored giga-alien"
     e.espr=6
     e.w=2
     e.h=2
     e.hp=20
    elseif e.entype == "armored giga-alien" then
     e.entype="shield giga-alien"
     e.espr=8
     e.w=2
     e.h=2
     e.hp=10
    elseif e.entype == "shield giga-alien" then
     e.entype="giga-alien"
     e.espr=66
     e.w=2
     e.h=2
     e.hp=30
    elseif e.entype == "giga-alien"  or e.entype == "giga-alien" then -- giga alien death
     del(enemies,e)
     enemynum-=1
     -- camp aliens and mounten aleins
    elseif e.entype == "camp alien" then
     e.entype="alien"
     e.espr=1
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "mounten climber" then
     e.entype="alien"
     e.espr=1
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "glow mounten climber" then
     e.entype="mounten climer"
     e.espr=68
     e.w=1
     e.h=1
     e.hp=4
     -- extra aliens
    elseif e.entype == "coronovirus alien" then
     --corono-virus aliens
     e.entype="alien"
     e.espr=1
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "coronovirus giga-alien" then
     e.entype="giga-alien"
     e.espr=66
     e.w=2
     e.h=2
     e.hp=10
    elseif e.entype == "lab alien" then
     -- facility aliens
     e.entype="alien"
     e.espr=89
     e.w=1
     e.h=1
     e.hp=2
    elseif e.entype == "lab giga-alien" then
     e.entype="giga-alien"
     e.espr=76
     e.w=1
     e.h=1
     e.hp=2
     -- artic aliens
    elseif e.entype == "yeti alien"  or e.entype == "giga-alien" then -- giga alien death
     del(enemies,e)
     minenum+=2
     enemynum-=1
    elseif e.entype == "yeti" then -- giga alien death
     del(enemies,e)
     minenum+=2
     enemynum-=1
    elseif e.entype == "cold zapper" then -- giga alien death
     del(enemies,e)
     minenum+=1
     enemynum-=1
     -- space ships
    elseif e.entype == "ufo" then -- giga alien death
     if e.entype == "ufo" then
      addenemy(0.9,1,1,e.x,e.y,25,"armored alien",2)
     end
     del(enemies,e)
     enemynum-=1
    elseif e.entype == "iufo"  or e.entype == "giga-alien" then -- giga alien death
     if e.entype == "iufo" then
      addenemy(0.9,1,1,e.x,e.y,25,"armored alien",2)
     end
     del(enemies,e)
     enemynum-=1
    elseif e.entype == "aliengen" then -- aliengen death
     del(enemies,e)
     enemynum-=1
    elseif e.entype == "yeti ufo"  or e.entype == "yeti iufo" then -- ufo death
     addenemy(0.9,1,1,e.x,e.y,45,"yeti",43)
     del(enemies,e)
     enemynum-=1
    end
   end
  end
 end
 if level == 0 and btnp(❎) then
  fs=0
  frames30persec=0
  score=1
  clearalies()
  score=1
  level=flr(rnd(maxlevels))+1
 end
 if score == 5 then
  maxlevels=4
 end
 if score == 10 then
  maxlevels=5
 end
 if score == 15 then
  maxlevels=6
 end
 if level == 1 then
  if fs == 50 then
   addenemy(0.4,1,1,16*8,7,2,"alien",1)
   addenemy(0.4,1,1,16*8,7*5,2,"alien",1)
  end
  if fs == 160 then
   addenemy(0.2,1,1,16*8,7*5,80,"ufo",101)
   addenemy(0.2,1,1,16*8,7*3,80,"iufo",101)
  end
  if fs > 300 and enemynum < 1 then
   complete()
  end
 end
 if level == 2 then
  if fs == 50 then
   addenemy(0.4,1,1,16*8,7,2,"armored alien",18)
  end
  if fs == 70 then
   addenemy(0,1,1,13*8,8*3,80,"aliengen",102)
  end
  if fs > 72 and enemynum < 1 then
   complete()
  end
 end
 if level == 3 then
  if fs == 10 then
   addenemy(0.2,2,2,18*8,60,8,"protected armored giga-alien",4)
   addenemy(0.2,2,2,18*8,60-8-8-8,8,"protected armored giga-alien",4)
   addenemy(0.2,2,2,18*8,60+8+8+8,8,"protected armored giga-alien",4)
  end
  if fs > 12 and enemynum < 1 then
   complete()
  end
 end
 if level == 4 then
  if fs == 10 then
   addenemy(0.2,2,2,18*8,60+16,8,"protected armored giga-alien",4)
   addenemy(0,2,2,7*8,60,8,"annom",96)
   enemynum-=1
  end
  if fs > 30 then
   for ufoy = 0,14 do
    addenemy(2,1,1,15*8,ufoy*8,40,"shield alien",3)
   end
  end
  if fs > 140 and enemynum < 1 then
   complete()
  end
 end
 if level == 5 then
  if fs == 10 then
   addenemy(0.2,2,2,18*8,60,8,"protected armored giga-alien",4)
   addenemy(0.2,2,2,18*8,60-8-8-8,8,"protected armored giga-alien",4)
   addenemy(0.2,2,2,18*8,60+8+8+8,8,"protected armored giga-alien",4)
  end
  if fs == 140 then
   addenemy(0.2,2,2,16*8,60,250,"yeti alien",46)
   newwave()
  end
 end
 if level == 6 then
  if fs == 20 then
   for ufoy = 0,14 do
    addenemy(0,1,1,15*8,ufoy*8,100,"yeti ufo",44)
   end
   newwave()
  end
 end
end
--aliens' health
--alien health = 2
--giga-alien health = 30
--protected/glow giga-alien health = 8
--protected/glow alien health = 4
--mounten climer health = 4
--glow mounten climer health = 6
--lab aliens/giga-alien = health+2
--coronovirus aliens/giga-alien = health+10
--yeti alien = 250
--yeti = 45
--yeti ufo/iufo = 100
--shield = 40

__gfx__
00000000888888886666666688888888555555555555555566666666666666668888888888888888006000000060000000660000006600000066600000666000
00000000a888888a6666666666666666555555555555555566666666666666668888888888888888067555000675550006775500067755000677750006777500
007007008a8888a86a8888a66666666655555555555555556666666666666666aa888888888888aa075555500775555007755550077755500777555007777550
0007700088988988689889866666666655555555555555556666666666666666aa888888888888aa075555500775555007755550077755500777555007777550
00077000889889886898898666666666559922222222995566aa88888888aa6688aa88888888aa88075555500775555007755550077755500777555007777550
00700700888888886888888666666666559922222222995566aa88888888aa6688aa88888888aa88075555500775555007755550077755500777555007777550
00000000888888886888888666666666552244222244225566889988889988668888998888998888007555000075550000775500007755000077750000777500
00000000888888888888888866666666552244222244225566889988889988668888998888998888000000000000000000000000000000000000000000000000
0000000b22222222dddddddd22222222555555552244225566666666889988446666666688998844006666000066660000666600009999000077770000099000
0000000092222229dddddddddddddddd55555555224422556666666688998844666666668899884406777700067777000677776009aaaa900766667000099000
0000000029222292d922229ddddddddd5555555522225555666666668888446666666666888844880777755007777750077777700aaaaaa006dddd6000000000
0000000022422422d242242ddddddddd5555555522225555666666668888446666666666888844880777755007777750077777700aaaaaa006d55d60990aa099
0000000022422422d242242ddddddddd5555555522552255666666668844886666666666884488880777755007777750077777700aaaaaa006d55d60990aa099
0000000022222222d222222ddddddddd5555555522552255666666668844886666666666884488880777755007777750077777700aaaaaa006dddd6000000000
0000000022222222d222222ddddddddd55555555552222226666666644888888666666664488888800777700007777000077770000aaaa000066660000099000
000000002222222222222222dddddddd555555555522222266666666448888886666666644888888000000000000000000000000000000000000000000099000
00000000eeeeeeee55555555eeeeeeee77777777777777775555555555555555eeeeeeeeeeeeeeee500000057777777700000000000aa0007777777777777777
000000004eeeeee4555555555555555577777777777777775555555555555555eeeeeeeeeeeeeeee08000080d777777d00000000000aa0007777777777777777
00000000e4eeee4e54eeee45555555557777777777777777555555555555555544eeeeeeeeeeee44008888007d7777d700666600000000007777777777777777
00ddddd0ee5ee5ee5e5ee5e5555555557777777777777777555555555555555544eeeeeeeeeeee44008dd8007767767700666600aa0990aadd777777777777dd
00d0d000ee5ee5ee5e5ee5e55555555577aabbbbbbbbaa775544eeeeeeee4455ee44eeeeeeee44ee008dd8007767767707777770aa0990aadd777777777777dd
0dd0d000eeeeeeee5eeeeee55555555577aabbbbbbbbaa775544eeeeeeee4455ee44eeeeeeee44ee0088880077777777077777700000000077dd77777777dd77
66666666eeeeeeee5eeeeee55555555577bb33bbbb33bb7755ee55eeee55ee55eeee55eeee55eeee080000807777777700000000000aa00077dd77777777dd77
66666666eeeeeeeeeeeeeeee5555555577bb33bbbb33bb7755ee55eeee55ee55eeee55eeee55eeee500000057777777700000000000aa0007777667777667777
00000000bbbbbbbb77777777bbbbbbbb77777777bb33bb7755555555ee55ee5555555555ee55ee55888888880000000088888888000000007777667777667777
00000000abbbbbba777777777777777777777777bb33bb7755555555ee55ee5555555555ee55ee55a888888abbbb0000a888888abbb000007777667777667777
000d0000babbbbab7abbbba77777777777777777bbbb777755555555eeee555555555555eeee55ee8a8888a8bbbb00008a8888a8bbb000007777667777667777
00ddddd0bb3bb3bb7b3bb3b77777777777777777bbbb777755555555eeee555555555555eeee55ee8898898bbbbb000088988983bbb000007777777777777777
00d00000bb3bb3bb7b3bb3b77777777777777777bb77bb7755555555ee55ee5555555555ee55eeee88988938bbbb000088988948bbb000007777777777777777
0ddd0000bbbbbbbb7bbbbbb77777777777777777bb77bb7755555555ee55ee5555555555ee55eeee88888488bbbb000088888488bbb000007777777777777777
66666666bbbbbbbb7bbbbbb7777777777777777777bbbbbb5555555555eeeeee5555555555eeeeee88884888bbbb000088884888bbb000007777777777777777
66666666bbbbbbbbbbbbbbbb777777777777777777bbbbbb5555555555eeeeee5555555555eeeeee88848888bbbb000088848888bbb000007777777777777777
eeeeeeeeeeeeeeee888888888888888888888888bbbbbbbb66666666666666666666666666666666666666666666666688888888888888881100110010011001
eeeeeeeeeeeeeeee8888888888888888a888888aabbbbbba66666666666666666666666646666664666666666666666688888888888888881001100100110011
44eeeeeeeeeeee44aa888888888888aa8a8888a8babbbbab666666666666666666666666646666464466666666666644aa888888888888aa0011001101100110
44eeeeeeeeeeee44aa888888888888aa88988988bb3bb3bb664664666666666666666666665665664466666666666644aa888888888888aa0110011011001100
ee44eeeeeeee44ee88aa88888888aa88689689887b37b3bb66466466666666666666666666566566664466666666446688aa88888888aa881100110010011001
ee44eeeeeeee44ee88aa88888888aa88688688887bb7bbbb66655666666666666666666666666666664466666666446688aa88888888aa881001100100110011
eeee55eeee55eeee8888998888998888688688887bb7bbbb666556666666446666446666cddd8888666655666655666688889988889988880011001101100110
eeee55eeee55eeee8888998888998888688688887bb7bbbb66666666666644666644666688888888666655666655666688889988889988880110011011001100
eeee55eeee55ee5588889988889988442222222288888888b000000066664466664466448888888866665566665566cc88889988889988cc0011001101100110
eeee55eeee55ee5588889988889988442cccccc280000008000000006666446666446644a888888a66665566665566cc88889988889988cc0110011011001100
eeeeeeeeeeee55ee88888888888844882dccccd2800000080000000066666655556644668a8888a8666666666666dd66888888888888dd881100110010011001
eeeeeeeeeeee55ee88888888888844882c1cc1c28000000800000000666666555566446688988988666666666666dd66888888888888dd881001100100110011
eeeeeeeeee55eeee88888888884488882c1cc1c280000008000000006666665555446666889889888888888888dd88888888888888dd88880011001101100110
eeeeeeeeee55eeee88888888884488882cccccc280000008000000006666665555446666888888888888888888dd88888888888888dd88880110011011001100
eeeeeeee55eeeeee88888888448888882cccccc280000008000000006666666644666666cddd888888888888dd88888888888888dd8888881100110010011001
eeeeeeee55eeeeee888888884488888822222222888888880000000066666666446666668888888888888888dd88888888888888dd8888881001100100110011
0000ddddd00000000000000000000000000000000000000006688660000a00000000000000000000000000000000000000000000000000000000000000000000
00000dccd00000000000000000000000000000000000000006688660000a00000000000000000000000000000000000000000000000000000000000000000000
00000dcccd000000000000000000000000bbbb0000bbbb0006688660000000000000000000000000000bbbbbbbbbb00000000000000000000000000000000000
000000dccd000000000000000000000000bbbb0000bbbb0006688660aa090aa00000000000000000000bbbbbbbbbb00000000000000000000000000000000000
000000dccd00000000000000000000000d6666d00666666006688660000000000000000000000000000bbbbbbbbbb00000000000000000000000000000000000
0000000dccd00000000000000000000005dddd500666666006688660000a00000000000000000000000bbbbbbbbbb00000000000000000000000000000000000
0000000dccd000000000000000000000000000000000000006688660000a00000000000000000000000bbbbbbbbbb00000000000000000000000000000000000
000000dcccd000000000000000000000000000000000000006888860000000000000000000000000666666666666666600000000000000000000000000000000
00000dcccd0000000000000000000000000000000000000000000000000000000000000000000000666666666666666600000000000000000000000000000000
000ddccdd00000000000000000000000000000000000000000000000000000000000000000000000666666666666666600000000000000000000000000000000
00dcccd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dccd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dccd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dccdd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000dcccd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014010800780000001401080078000000000000000000000000000000000000
__sfx__
001000000001000020000300004000050000400f00010000110001100012000120001200012000120001100011000110000000000000000000000000000000000000000000000000000000000000000000000000
001000000007000060000500004000030000200001001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
471000001d6102a6003e6003e6003e600226001a60014600136000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
470100002d670156701c6702a6701e670246702867018670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
460400003c650356502b650246501d650156500a65002650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
