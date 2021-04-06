//
//  NTESFontMacro.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef NTESFontMacro_h
#define NTESFontMacro_h
//字号
#define Font_Size(fname,fsize) [UIFont fontWithName:fname size:fsize]

#define Font_Default(fsize) [UIFont systemFontOfSize:fsize]
//13号字体
#define TextFont_13 Font_Default(13)
//14号字体
#define TextFont_14 Font_Default(14)
//15号字体
#define TextFont_15 Font_Default(15)
//16号字体
#define TextFont_16 Font_Default(16)
//17号字体
#define TextFont_17 Font_Default(17)
//18号字体
#define TextFont_18 Font_Default(18)
//20号字体
#define TextFont_20 Font_Default(20)




#define Chatroom_Message_Font [UIFont boldSystemFontOfSize:14] // 聊天室聊天文字字体

#endif /* NTESFontMacro_h */
