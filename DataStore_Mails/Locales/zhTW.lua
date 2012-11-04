local L = LibStub("AceLocale-3.0"):NewLocale( "DataStore_Mails", "zhTW" )

if not L then return end

L["Check mail expiries on all known accounts"] = "檢查所有已知帳戶的將屆滿郵件"
L["Check mail expiries on all known realms"] = "檢查所有已知伺服器的將屆滿郵件"
L["EXPIRY_ALL_ACCOUNTS_DISABLED"] = "只有目前帳戶將予以考慮;滙入的帳戶將被忽略."
L["EXPIRY_ALL_ACCOUNTS_ENABLED"] = "屆滿檢查例程將會撿查所有已知帳戶內將過期的郵件."
L["EXPIRY_ALL_ACCOUNTS_TITLE"] = "撿查所有帳戶"
L["EXPIRY_ALL_REALMS_DISABLED"] = "只有目前的伺服器將予以考慮;其它的伺服器將被忽略."
L["EXPIRY_ALL_REALMS_ENABLED"] = "屆滿檢查例程將會撿查所有伺服器內將過期的郵件."
L["EXPIRY_ALL_REALMS_TITLE"] = "撿查所有伺服器"
L["EXPIRY_CHECK_DISABLED"] = "不會執行郵件屆滿檢查."
L["EXPIRY_CHECK_ENABLED"] = "上線5秒後將執行郵件屆滿檢查. 如果至少一個過期的郵件被發現, 客戶端插件將得到通知."
L["EXPIRY_CHECK_TITLE"] = "郵件屆滿檢查"
L["Mail Expiry Warning"] = "郵件屆滿警告"
L["SCAN_MAIL_BODY_DISABLED"] = "只有郵件附件將被讀取。郵件將保持未讀取的狀態."
L["SCAN_MAIL_BODY_ENABLED"] = "掃描時郵箱裡每個郵件的內容將被讀取。所有郵件將被標記為已讀取."
L["Scan mail body (marks it as read)"] = "掃描郵件內容 (標記為己讀取)"
L["SCAN_MAIL_BODY_TITLE"] = "掃描郵件內容"
L["Warn when mail expires in less days than this value"] = "當郵件屆滿少過此值的日數時發出警告"

