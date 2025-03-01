----------------------------------------------------------------------------------------------------
-- Module Initialization
----------------------------------------------------------------------------------------------------

function Init()
	local m = NewWebsiteModule()
	m.ID                       = 'd297f1eb6b784ded9b50d3b85cee5276'
	m.Name                     = 'MangaNeko'
	m.RootURL                  = 'https://www.mgeko.com'
	m.Category                 = 'English'
	m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
	m.OnGetNameAndLink         = 'GetNameAndLink'
	m.OnGetInfo                = 'GetInfo'
	m.OnGetPageNumber          = 'GetPageNumber'
	m.SortedList               = true
end

----------------------------------------------------------------------------------------------------
-- Local Constants
----------------------------------------------------------------------------------------------------

DirectoryPagination = '/browse-comics/?results=%s&filter=New'

----------------------------------------------------------------------------------------------------
-- Event Functions
----------------------------------------------------------------------------------------------------

-- Get the page count of the manga list of the current website.
function GetDirectoryPageNumber()
	local u = MODULE.RootURL .. DirectoryPagination:format('1')

	if not HTTP.GET(u) then return net_problem end

	PAGENUMBER = tonumber(CreateTXQuery(HTTP.Document).XPathString('(//ul[@class="pagination"])[1]/li[last()-1]')) or 1

	return no_error
end

-- Get links and names from the manga list of the current website.
function GetNameAndLink()
	local v, x = nil
	local u = MODULE.RootURL .. DirectoryPagination:format((URL + 1))

	if not HTTP.GET(u) then return net_problem end

	CreateTXQuery(HTTP.Document).XPathHREFTitleAll('//li[@class="novel-item"]/a', LINKS, NAMES)

	return no_error
end

-- Get info and chapter list for current manga.
function GetInfo()
	local v, x = nil
	local u = MaybeFillHost(MODULE.RootURL, URL)

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	MANGAINFO.Title     = x.XPathString('//h1[contains(@class, "title")]/substring-before(., "[All Chapters]")')
	MANGAINFO.CoverLink = x.XPathString('//figure[@class="cover"]/img/@data-src')
	MANGAINFO.Authors   = x.XPathString('//span[@itemprop="author"]')
	MANGAINFO.Genres    = x.XPathStringAll('//div[@class="categories"]//a')
	MANGAINFO.Status    = MangaInfoStatusIfPos(x.XPathString('//span[contains(., "Status")]/parent::*'))
	MANGAINFO.Summary   = x.XPathString('//p[@class="description"]')

	for v in x.XPath('//ul[@class="chapter-list"]//a').Get() do
		MANGAINFO.ChapterNames.Add(x.XPathString('strong/replace(., "-eng-li", " [EN]")', v))
		MANGAINFO.ChapterLinks.Add(v.GetAttribute('href'))
	end
	MANGAINFO.ChapterLinks.Reverse(); MANGAINFO.ChapterNames.Reverse()

	return no_error
end

-- Get the page count for the current chapter.
function GetPageNumber()
	local u = MaybeFillHost(MODULE.RootURL, URL)

	if not HTTP.GET(u) then return net_problem end

	CreateTXQuery(HTTP.Document).XPathStringAll('//section[@class="page-in content-wrap"]//center/div/img/@src', TASK.PageLinks)

	return no_error
end
