---@class Coolape.WWWEx : UnityEngine.MonoBehaviour
---@field public self Coolape.WWWEx
---@field public wwwMapUrl System.Collections.Hashtable
---@field public wwwMap4Check System.Collections.Hashtable
---@field public wwwMap4Get System.Collections.Hashtable
---@field public checkTimeOutSec System.Int32
---@field public isCheckWWWTimeOut System.Boolean
---@field public isPrintUrl System.Boolean
local m = { }
---public WWWEx .ctor()
---@return WWWEx
function m.New() end
---public UnityWebRequest get(String url, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.get(url, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public UnityWebRequest post(String url, String jsonMap, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---public UnityWebRequest post(String url, Hashtable map, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---public UnityWebRequest post(String url, WWWForm data, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional WWWForm data
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.post(url, data, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public UnityWebRequest postString(String url, String strData, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional String strData
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.postString(url, strData, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public UnityWebRequest postBytes(String url, Byte[] bytes, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional Byte[] bytes
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.postBytes(url, bytes, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public UnityWebRequest put(String url, String data, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---public UnityWebRequest put(String url, Byte[] data, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional Byte[] data
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.put(url, data, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public UnityWebRequest uploadFile(String url, String sectionName, String fileName, Byte[] fileContent, CLAssetType t, Object successCallback, Object failedCallback, Object orgs, Boolean isCheckTimeout, Int32 maxFailTimes)
---@return UnityWebRequest
---@param optional String url
---@param optional String sectionName
---@param optional String fileName
---@param optional Byte[] fileContent
---@param optional CLAssetType t
---@param optional Object successCallback
---@param optional Object failedCallback
---@param optional Object orgs
---@param optional Boolean isCheckTimeout
---@param optional Int32 maxFailTimes
function m.uploadFile(url, sectionName, fileName, fileContent, type, successCallback, failedCallback, orgs, isCheckTimeout, maxFailTimes) end
---public Void addCheckWWWTimeout(UnityWebRequest www, String url, Single checkProgressSec, Object timeoutCallback, Object orgs, Int32 maxFailTimes, Int32 failedTimes, RedCallback redrectioncallback)
---@param optional UnityWebRequest www
---@param optional String url
---@param optional Single checkProgressSec
---@param optional Object timeoutCallback
---@param optional Object orgs
---@param optional Int32 maxFailTimes
---@param optional Int32 failedTimes
---@param optional RedCallback redrectioncallback
function m.addCheckWWWTimeout(www, url, checkProgressSec, timeoutCallback, orgs, maxFailTimes, failedTimes, redrectioncallback) end
---public Void checkWWWTimeout()
function m.checkWWWTimeout() end
---public Void doCheckWWWTimeout(UnityWebRequest www, NewList list)
---@param optional UnityWebRequest www
---@param optional NewList list
function m.doCheckWWWTimeout(www, list) end
---public Void uncheckWWWTimeout(UnityWebRequest www, String url)
---@param optional UnityWebRequest www
---@param optional String url
function m.uncheckWWWTimeout(www, url) end
---public UnityWebRequest getWwwByUrl(String Url)
---@return UnityWebRequest
---@param optional String Url
function m.getWwwByUrl(Url) end
Coolape.WWWEx = m
return m
