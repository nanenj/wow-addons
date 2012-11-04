local L = LibStub("AceLocale-3.0"):NewLocale( "DataStore_Auctions", "koKR" )

if not L then return end

L["Automatically clear expired auctions and bids"] = "자동으로 만기된 경매와 입찰 지움"
L["CLEAR_ITEMS_DISABLED"] = "만기된 아이템이 플레이어가 다음에 경매장을 찾을 때까지 데이터베이스에 남습니다."
L["CLEAR_ITEMS_ENABLED"] = "만기된 아이템은 자동으로 데이터베이스에서 지워집니다."
L["CLEAR_ITEMS_TITLE"] = "경매장 아이템 지우기"

