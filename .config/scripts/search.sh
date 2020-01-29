#!/bin/sh
link=0
case "$1" in 
	google)
		link="https://www.google.com/search?q="
		;;
	bing)
		link="https://www.bing.com/search?q="
		;;
	yahoo)
		link="https://search.yahoo.com/search?p="
		;;
	duckduckgo)
		link="https://www.duckduckgo.com/?q="
		;;
	startpage)
		link="https://www.startpage.com/do/search?q="
		;;
	yandex)
		link="https://yandex.ru/yandsearch?text="
		;;
	github)
		link="https://github.com/search?q="
		;;
	baidu)
		link="https://www.baidu.com/s?wd="
		;;
	ecosia)
		link="https://www.ecosia.org/search?q="
		;;
	goodreads)
		link="https://www.goodreads.com/search?q="
		;;
	qwant)
		link="https://www.qwant.com/?q="
		;;
	givero)
		link="https://www.givero.com/search?q="
		;;
	stackoverflow)
		link="https://stackoverflow.com/search?q="
		;;
	*)
		echo "Search engine not supported"
		exit 1
		;;
esac
shift 1

search=$(echo "$*" | tr " " "+")
$BROWSER "$link$search"


#alias google='web_search google'
#alias ddg='web_search duckduckgo'
#alias sp='web_search startpage'
#alias github='web_search github'
#alias stackoverflow='web_search stackoverflow'
#
##add your own !bang searches here
#alias wiki='web_search duckduckgo \!w'
#alias news='web_search duckduckgo \!n'
#alias youtube='web_search duckduckgo \!yt'
#alias map='web_search duckduckgo \!m'
#alias image='web_search duckduckgo \!i'
#alias ducky='web_search duckduckgo \!'
