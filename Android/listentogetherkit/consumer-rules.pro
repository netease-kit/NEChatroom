#IM SDK https://doc.yunxin.163.com/docs/TM5MzM5Njk/zU4NzUxNjI?platformId=60002#%E6%B7%B7%E6%B7%86%E9%85%8D%E7%BD%AE
-dontwarn com.netease.**
-keep class com.netease.** {*;}
#如果你使用全文检索插件，需要加入
-dontwarn org.apache.lucene.**
-keep class org.apache.lucene.** {*;}
#如果你开启数据库功能，需要加入
-keep class net.sqlcipher.** {*;}

#Rtc SDK https://doc.yunxin.163.com/docs/zUyNzE0ODI/DAyMjQ2NzA?platformId=2
-keep class com.netease.lava.** {*;}
-keep class com.netease.yunxin.** {*;}

-keep class com.netease.yunxin.kit.roomkit.impl.model.** {*;}