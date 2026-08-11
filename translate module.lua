local request =
    request or
    http_request or
    syn and syn.request or
    fluxus and fluxus.request

assert(request, "request function not found")

local countryCache
local languageCache

local languageMap = {
    TH = "th",
    US = "en",
    GB = "en",
    JP = "ja",
    KR = "ko",
    CN = "zh-CN",
    TW = "zh-TW",
    FR = "fr",
    DE = "de",
    ES = "es",
    IT = "it",
    PT = "pt",
    RU = "ru",
    VN = "vi",
    ID = "id",
    MY = "ms",
    PH = "tl",
    TR = "tr",
    IN = "hi",
    SA = "ar",
}

local function getCountry()
    if countryCache then
        return countryCache
    end

    local res = request({
        Url = "https://ipapi.co/json/",
        Method = "GET"
    })

    if not res.Success then
        return "US"
    end

    local data = game:GetService("HttpService"):JSONDecode(res.Body)

    countryCache = data.country_code or "US"
    languageCache = languageMap[countryCache] or "en"

    return countryCache
end

local function translate(text, fromLang)
    getCountry()

    local target = languageCache or "en"
    fromLang = fromLang or "auto"

    local url = string.format(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s",
        fromLang,
        target,
        game:GetService("HttpService"):UrlEncode(text)
    )

    local res = request({
        Url = url,
        Method = "GET"
    })

    if not res.Success then
        return text
    end

    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(res.Body)
    end)

    if ok and data and data[1] and data[1][1] then
        return data[1][1][1]
    end

    return text
end

