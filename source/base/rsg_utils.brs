' ********** Copyright 2017 Roku Corp.  All Rights Reserved. **********

' Converts associative array to a node of a given type
' @param inputAA associative array, which will be transformed to roSGNode
' @param nodeType type of node, which will be created
function Utils_AAToNode(inputAA = {} as Object, nodeType = "Node" as String) as Object
    node = createObject("roSGNode", nodeType)

    Utils_forceSetFields(node, inputAA)

    return node
end function


'converts AA to ContentNode
Function Utils_AAToContentNode(inputAA = {} as Object, nodeType = "ContentNode" as String)
    return Utils_AAToNode(inputAA, nodeType)
End Function


' Force sets fields to a given node. If node doesn't have a field, it adds it and then sets
' @param node roSGNode, to which you want to set fields
' @param fieldsToSet associative array of field names and values to be set
sub Utils_forceSetFields(node as Object, fieldsToSet as Object)
    ' if not fw_isSGNode(node) or not fw_isAssociativeArray(fieldsToSet) then return

    existingFields = {}
    newFields = {}

      'AA of node read-only fields for filtering'
    fieldsFilterAA = {
        focusedChild    :   "focusedChild"
        change          :   "change"
        metadata        :   "metadata"
    }

    for each field in fieldsToSet
        if node.hasField(field)
            if NOT fieldsFilterAA.doesExist(field) then existingFields[field] = fieldsToSet[field]
        else
            newFields[field] = fieldsToSet[field]
        end if
    end for

    node.setFields(existingFields)
    node.addFields(newFields)
end sub


'converts array of AAs to content node with child content nodes
Function Utils_ContentList2Node(contentList as Object) as Object
    result = createObject("roSGNode","ContentNode")

    for each itemAA in contentList
        item = Utils_AAToContentNode(itemAA, "ContentNode")
        result.appendChild(item)
    end for

    return result
End Function

'
' The following utilities were added for the BoxCast application
'

function Utils_GetCurrentDateTimeString()
  return CreateObject("roDateTime").ToISOString()
end function

function Utils_GetCurrentDateTimeSeconds()
  return CreateObject("roDateTime").AsSeconds()
end function

function Utils_FormatDateForDisplay(dateString)
  date = CreateObject("roDateTime")
  date.ToLocalTime()
  todayString = date.AsDateString("short-date-dashes")

  date.FromISO8601String(dateString)
  date.ToLocalTime()
  if date.AsDateString("short-date-dashes") = todayString
    ' It's today! Just return time
    return Utils_FormatTimeForDisplay(dateString)
  else
    ' Not today, return date + time
    return date.AsDateString("short-month-no-weekday") + " " + Utils_FormatTimeForDisplay(dateString)
  end if
end function

function Utils_CalculateDurationSeconds(startDateString, endDateString)
  startSec = CreateObject("roDateTime")
  startSec.FromISO8601String(startDateString)
  startSec = startSec.AsSeconds()
  endSec = CreateObject("roDateTime")
  endSec.FromISO8601String(endDateString)
  endSec = endSec.AsSeconds()
  return endSec - startSec
end function

function Utils_FormatTimeForDisplay(dateString)
   datetime = CreateObject( "roDateTime" )
   datetime.FromISO8601String(dateString)
   datetime.ToLocalTime()

   hours = datetime.GetHours()
   minutes = datetime.GetMinutes()

   if hours = 24
     hours = 12
     ampm = "am"
   else if hours > 12
     hours = hours - 12
     ampm = "pm"
   else if hours = 12
     ampm = "pm"
   else
     ampm = "am"
   end if
   hours = hours.ToStr()

   minutes = minutes.ToStr()
   If Len(minutes.ToStr()) = 1 Then
      minutes = "0" + minutes
   End If

   return hours.ToStr() + ":" + minutes + " " + ampm
end function

function Utils_ShallowCopy(array As Dynamic, depth = 0 As Integer) As Dynamic
  if Type(array) = "roArray" then
    copy = []
    for each item in array
      childCopy = Utils_ShallowCopy(item, depth)
      if childCopy <> invalid then
          copy.Push(childCopy)
      end if
    next
    return copy
  else if Type(array) = "roAssociativeArray" then
    copy = {}
    for each key in array
      if depth > 0 then
        copy[key] = Utils_ShallowCopy(array[key], depth - 1)
      else
        copy[key] = array[key]
      end if
    next
    return copy
  else
    return array
  end if
  return Invalid
end function

Function Utils_validstr(obj As Dynamic) As String
    if Utils_isnonemptystr(obj) return obj
    return ""
End Function

Function Utils_isnonemptystr(obj)
    if Utils_isnullorempty(obj) return false
    return true
End Function


Function Utils_isnullorempty(obj)
    if obj = invalid return true
    if not Utils_isstr(obj) return true
    if Len(obj) = 0 return true
    return false
End Function

Function Utils_isstr(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifString") = invalid return false
    return true
End Function

Function Utils_strReplace(basestr As String, oldsub As String, newsub As String) As String
    newstr = ""

    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif

        if x > i then
            newstr = newstr + Mid(basestr, i, x-i)
            i = x
        endif

        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while

    return newstr
End Function
