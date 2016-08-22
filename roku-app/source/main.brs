' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

 sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()

    list = [
        {
            Title:"Manually input some movies of Charlie Chaplin"
            ContentList : CharlieChaplinArray()
        }
        {
            Title:"Reading Json from thw crawler result"
            ContentList : ReadJsonAndParse()
        }
        {
            Title:"The example row from Roku website"
            ContentList : GetApiArray()
        }
    ]
    scene.gridContent = ParseXMLContent(list)

    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; msg
    end while

    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
end sub


Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")

    for each rowAA in list
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for

    return RowItems
End Function

Function CharlieChaplinArray()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://45.55.239.146/charlie_chaplin.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()

    result = []

    for each xmlItem in responseArray
        if xmlItem.getName() = "item"
            itemAA = xmlItem.GetChildElements()
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"
                        item.stream = {url : xmlItem.url}
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "mp4"

                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterUrl = mediaContentItem.getattributes().url
                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for
                    end if
                end for
                result.push(item)
            end if
        end if
    end for

    return result
End Function

Function GetApiArray()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://45.55.239.146/sample.rss")
    rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()

    result = []

    for each xmlItem in responseArray
        if xmlItem.getName() = "item"
            itemAA = xmlItem.GetChildElements()
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"
                        item.stream = {url : xmlItem.url}
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "mp4"

                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterUrl = mediaContentItem.getattributes().url
                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for
                    end if
                end for
                result.push(item)
            end if
        end if
    end for

    return result
End Function

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function


Function ReadJsonAndParse()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("http://45.55.239.146/sample.json")
    rsp = url.GetToString()
    m.json = ParseJSON(rsp)
    
    result = []
    for each video in m.json.Videos
        
        item = {}
        item.title = video.title
        item.url = video.video_url
        item.description = video.description
        item.streamFormat = "mp4"
        item.HDPosterUrl = "http://investorsconundrum.com/wp-content/uploads/2008/02/charlie_chaplin_04.jpg"
        item.hdBackgroundImageUrl = video.thumbnail
        
        result.push(item)
    end for
    
    return result
End Function