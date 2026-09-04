/// 주문·유물 아이콘 픽셀아트 (16×16). 글자 규약은 pixel_sprite.dart 참조.
library;

import 'pixel_sprite.dart';

/// 마력 구슬 — 투사체 주문 공용 (색조로 속성 구분)
const kIconOrb = PixelSprite([
  '................',
  '......kkkk......',
  '....kk2222kk....',
  '...k22222222k...',
  '..k2233333322k..',
  '..k2335555332k..',
  '.k23355555533k..',
  '.k23555555533k..',
  '.k23555555533k..',
  '.k23355555533k..',
  '..k2335555332k..',
  '..k2233333322k..',
  '...k22222222k...',
  '....kk2222kk....',
  '......kkkk......',
  '................',
]);

/// 얼음 파편 — 냉기 주문
const kIconShard = PixelSprite([
  '................',
  '.......kk.......',
  '......k55k......',
  '.....k5445k.....',
  '....k544445k....',
  '...k54444445k...',
  '..k5444444445k..',
  '.k544444444445k.',
  '.k234444444432k.',
  '..k2344444432k..',
  '...k23444432k...',
  '....k233332k....',
  '.....k2332k.....',
  '......k22k......',
  '.......kk.......',
  '................',
]);

/// 방패 — 방어막 효과
const kIconShield = PixelSprite([
  '................',
  '..kkkkkkkkkkkk..',
  '.k333333333333k.',
  '.k444444444444k.',
  '.k445555555554k.',
  '.k445555555554k.',
  '.k445555555554k.',
  '.k445555555554k.',
  '.k444555555444k.',
  '..k4455555554k..',
  '..k4445555544k..',
  '...k444555444k..',
  '....k4444444k...',
  '.....k44444k....',
  '......kkkk......',
  '................',
]);

/// 심장 — 회복·최대 체력
const kIconHeart = PixelSprite([
  '................',
  '..kkkk....kkkk..',
  '.krrrrk..krrrrk.',
  'krrrrrrkkrrrrrrk',
  'krrwwrrrrrrrrrrk',
  'krrwwrrrrrrrrrrk',
  'krrrrrrrrrrrrrrk',
  '.krrrrrrrrrrrrk.',
  '..krrrrrrrrrrk..',
  '...krrrrrrrrk...',
  '....krrrrrrk....',
  '.....krrrrk.....',
  '......krrk......',
  '.......kk.......',
  '................',
  '................',
]);

/// 잎사귀 — 자연 주문
const kIconLeaf = PixelSprite([
  '................',
  '...........kk...',
  '.........kk55k..',
  '........k5555k..',
  '.......k44555k..',
  '......k444555k..',
  '.....k344455k...',
  '....k3344455k...',
  '...k33444555k...',
  '..k334445553k...',
  '.nk34445553k....',
  '.nk3445553k.....',
  '.nkk33333k......',
  '.n..kkkkk.......',
  '.n..............',
  '................',
]);

/// 별 — 비전·빛 주문
const kIconStar = PixelSprite([
  '................',
  '.......kk.......',
  '.......55.......',
  '...k...55...k...',
  '...k5..55..5k...',
  '....k5.55.5k....',
  '.....k55555k....',
  'kk555555555555kk',
  'k55555555555555k',
  '.....k55555k....',
  '....k5.55.5k....',
  '...k5..55..5k...',
  '...k...55...k...',
  '.......55.......',
  '.......kk.......',
  '................',
]);

/// 해골 — 그림자·저주 주문
const kIconSkull = PixelSprite([
  '................',
  '...kkkkkkkkkk...',
  '..kbbbbbbbbbbk..',
  '.kbbbbbbbbbbbbk.',
  '.kbbkkbbbbkkbbk.',
  '.kbkkkkbbkkkkbk.',
  '.kbkkkkbbkkkkbk.',
  '.kbbkkbbbbkkbbk.',
  '.kbbbbbbbbbbbbk.',
  '..kbbbkkkkbbbk..',
  '..kbbkbkbkbbbk..',
  '...kbbbbbbbbk...',
  '....kbkbkbkk....',
  '....kbbbbbbk....',
  '.....kkkkkk.....',
  '................',
]);

/// 번개 — 마력 축적 관련
const kIconBolt = PixelSprite([
  '................',
  '.........kk.....',
  '........k55k....',
  '.......k55k.....',
  '......k55k......',
  '.....k55kkkkk...',
  '....k5555555k...',
  '....k5555555k...',
  '.....kkk55k.....',
  '.......k55k.....',
  '......k55k......',
  '.....k55k.......',
  '....k55k........',
  '....kk..........',
  '................',
  '................',
]);

/// 주사위 — 판정 확률 관련 유물
const kIconDice = PixelSprite([
  '................',
  '.kkkkkkkkkkkkkk.',
  '.kwwwwwwwwwwwwk.',
  '.kwkkwwwwwwwwwk.',
  '.kwkkwwwwwwwwwk.',
  '.kwwwwwwwwwwwwk.',
  '.kwwwwwkkwwwwwk.',
  '.kwwwwwkkwwwwwk.',
  '.kwwwwwwwwwwwwk.',
  '.kwwwwwwwwwkkwk.',
  '.kwwwwwwwwwkkwk.',
  '.kwwwwwwwwwwwwk.',
  '.kwwwwwwwwwwwwk.',
  '.kkkkkkkkkkkkkk.',
  '................',
  '................',
]);

/// 금화 — 기본 유물
const kIconCoin = PixelSprite([
  '................',
  '.....kkkkkk.....',
  '...kkyyyyyykk...',
  '..kyywwwwwwyyk..',
  '.kyywwyyyywwyyk.',
  '.kywwyywwyywwyk.',
  '.kywyywwwwyywyk.',
  '.kywyywwwwyywyk.',
  '.kywwyywwyywwyk.',
  '.kyywwyyyywwyyk.',
  '..kyywwwwwwyyk..',
  '...kkyyyyyykk...',
  '.....kkkkkk.....',
  '................',
  '................',
  '................',
]);

/// 반지 — 판정 보정 유물
const kIconRing = PixelSprite([
  '................',
  '.......kk.......',
  '......kcck......',
  '.....kcccck.....',
  '....kkyyyykk....',
  '...kyywwwwyyk...',
  '..kywwykkywwyk..',
  '..kywyk..kywyk..',
  '..kywyk..kywyk..',
  '..kywwykkywwyk..',
  '...kyywwwwyyk...',
  '....kkyyyykk....',
  '......kkkk......',
  '................',
  '................',
  '................',
]);

/// 물약 — 회복 유물
const kIconPotion = PixelSprite([
  '................',
  '.....kkkkkk.....',
  '.....knnnnk.....',
  '......knnk......',
  '......knnk......',
  '.....kk33kk.....',
  '....k333333k....',
  '...k33333333k...',
  '..k3355333333k..',
  '..k3555333333k..',
  '..k3355333333k..',
  '..k3333333333k..',
  '...k33333333k...',
  '....kkkkkkkk....',
  '................',
  '................',
]);

/// 마법서 — 주문 관련
const kIconBook = PixelSprite([
  '................',
  '.kkkkkkkkkkkkkk.',
  '.knnnnnnnnnnnnk.',
  '.knwwwwwwwwwwnk.',
  '.knw333wwww33nk.',
  '.knwwwwwwwwwwnk.',
  '.knw333wwww33nk.',
  '.knwwwwwwwwwwnk.',
  '.knw333wwww33nk.',
  '.knwwwwwwwwwwnk.',
  '.knw333wwww33nk.',
  '.knwwwwwwwwwwnk.',
  '.knnnnnnnnnnnnk.',
  '.kkkkkkkkkkkkkk.',
  '................',
  '................',
]);

/// 보석 — 마력 결정
const kIconGem = PixelSprite([
  '................',
  '....kkkkkkkk....',
  '...k55555555k...',
  '..k5444444445k..',
  '.k534444444435k.',
  '.k533444444335k.',
  '..k5334444335k..',
  '..k5334444335k..',
  '...k53344335k...',
  '...k53344333k...',
  '....k533335k....',
  '.....k5335k.....',
  '......k55k......',
  '.......kk.......',
  '................',
  '................',
]);

/// 편자 — 행운 유물
const kIconHorseshoe = PixelSprite([
  '................',
  '.....kkkkkk.....',
  '...kkmmmmmmkk...',
  '..kmmwwwwwwmmk..',
  '.kmmww....wwmmk.',
  '.kmww......wwmk.',
  '.kmww......wwmk.',
  '.kmww......wwmk.',
  '.kmww......wwmk.',
  '.kmww......wwmk.',
  '.kmmww....wwmmk.',
  '..kmmw....wmmk..',
  '..kkmk....kmkk..',
  '....k......k....',
  '................',
  '................',
]);

/// 모래시계 — 리롤·시간 유물
const kIconHourglass = PixelSprite([
  '................',
  '..kkkkkkkkkkkk..',
  '..knnnnnnnnnnk..',
  '..kkwwwwwwwwkk..',
  '...kwwwwwwwwk...',
  '....kwwwwwwk....',
  '.....kwwwwk.....',
  '......kwwk......',
  '......kwwk......',
  '.....kwwwwk.....',
  '....kwwwwwwk....',
  '...kwwwwwwwwk...',
  '..kkwwwwwwwwkk..',
  '..knnnnnnnnnnk..',
  '..kkkkkkkkkkkk..',
  '................',
]);

/// 검 — 대미지 증가 유물
const kIconSword = PixelSprite([
  '................',
  '............kkk.',
  '...........kmmk.',
  '..........kmmwk.',
  '.........kmmwk..',
  '........kmmwk...',
  '.......kmmwk....',
  '......kmmwk.....',
  '.kkk.kmmwk......',
  '.kyykmmwk.......',
  '.kyyymwk........',
  '..kyyyyk........',
  '..knkyyk........',
  '.knk..kk........',
  'kn..............',
  '................',
]);
