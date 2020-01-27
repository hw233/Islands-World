using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace Coolape
{
    public class CLPreLoadRes4Webgl
    {
        public static Hashtable resCache4Webgl = new Hashtable();
        static string baseUrl = ""; //--"http.//gamesres.ultralisk.cn/cdn/test";
        static string platform = "";
        static string newestVerPath = "newestVers";
        static string resVer = "resVer";
        static string versPath = "VerCtl";
        static string fverVer = "VerCtl.ver"; //--本地所有版本的版本信息
                                              //---@type System.Collections.Hashtable
        static Hashtable localverVer = new Hashtable();
        //---@type System.Collections.Hashtable
        static Hashtable serververVer = new Hashtable();
        //--========================
        static string verPriority = "priority.ver";
        //---@type System.Collections.Hashtable
        static Hashtable localPriorityVer = new Hashtable(); //--本地优先更新资源
                                                             //---@type System.Collections.Hashtable
        static Hashtable serverPriorityVer = new Hashtable(); //--服务器优先更新资源

        static string verOthers = "other.ver";
        //---@type System.Collections.Hashtable
        static Hashtable otherResVerOld = new Hashtable(); //--所有资源的版本管理
                                                           //---@type System.Collections.Hashtable
        static Hashtable otherResVerNew = new Hashtable(); //--所有资源的版本管理

        static string tmpUpgradePirorityPath = "tmpUpgrade4Pirority";
        static bool haveUpgrade = false;

        static object onFinishInit = null;
        static object progressCallback = null;
        static string mVerverPath = "";
        static string mVerPrioriPath = "";
        static string mVerOtherPath = "";

        //---@type System.Collections.Hashtable
        static Hashtable needUpgradeVerver = new Hashtable();
        static int progress = 0;

        static bool isNeedUpgradePriority = false;
        static Queue needUpgradePrioritis = new Queue();
        static bool isSucessUpgraded = false;
        static string verVerMD5 = "";

        public static byte[] getContent(string fileName)
        {
            return MapEx.getBytes(resCache4Webgl, fileName);
        }

        ///  iprogressCallback. 进度回调，回调有两个参数
        ///  ifinishCallback. 完成回调
        ///  isdoUpgrade. 是否做更新处理
        public static void init(object iprogressCallback, object ifinishCallback, bool isdoUpgrade, string _verVerMD5)
        {
            haveUpgrade = false;
            verVerMD5 = _verVerMD5;
            baseUrl = CLVerManager.self.baseUrl;
            //CLVerManager.self.haveUpgrade = false;
            isNeedUpgradePriority = false;
            localverVer.Clear();
            serververVer.Clear();
            localPriorityVer.Clear();
            serverPriorityVer.Clear();
            otherResVerOld.Clear();
            otherResVerNew.Clear();
            platform = CLPathCfg.self.platform;
            CLVerManager.self.platform = platform;

            mVerverPath = PStr.begin().a(CLPathCfg.self.basePath).a("/").a(resVer).a("/").a(platform).a("/").a(fverVer).e();
            mVerPrioriPath = PStr.begin().a(CLPathCfg.self.basePath).a("/").a(resVer).a("/").a(platform).a("/").a(versPath).a("/").a(verPriority).e();
            mVerOtherPath = PStr.begin().a(CLPathCfg.self.basePath).a("/").a(resVer).a("/").a(platform).a("/").a(versPath).a("/").a(verOthers).e();
            CLVerManager.self.mVerverPath = mVerverPath;
            CLVerManager.self.mVerPrioriPath = mVerPrioriPath;
            CLVerManager.self.mVerOtherPath = mVerOtherPath;

            progressCallback = iprogressCallback;
            onFinishInit = ifinishCallback;
            getServerVerverMap();
        }

        /// <summary>
        /// Gets the server verver map.取得服务器版本文件的版本信息
        /// </summary>
        static void getServerVerverMap()
        {
            string url = "";
            //if (CLCfgBase.self.hotUpgrade4EachServer)
            //{
            //    //-- 说明是每个服务器单独处理更新控制
            //    url = PStr.begin().a(baseUrl).a("/").a(mVerverPath).a(".").a(verVerMD5).e();
            //}
            //else
            //{
            //    url = PStr.begin().a(baseUrl).a("/").a(mVerverPath).e();
            //}
            url = PStr.begin().a(baseUrl).a("/").a(mVerverPath).e();

            WWWEx.get(
            Utl.urlAddTimes(url), //加了时间戳，保证一定会取得最新的
            CLAssetType.bytes,
            (Callback)onGetServerVerverBuff,
            (Callback)onGetServerVerverBuff, null, true);
        }

        static void onGetServerVerverBuff(params object[] param)
        {
            byte[] content = param[0] as byte[];
            object orgs = param[1];
            if (content != null)
            {
                serververVer = CLVerManager.self.toMap(content);
            }
            else
            {
                serververVer = new Hashtable();
                Debug.LogError("取得服务器版本文件的版本信息 error!!!!");
            }
            //--判断哪些版本控制信息需要更新
            checkVervers();
        }

        static void checkVervers()
        {
            progress = 0;
            needUpgradeVerver.Clear();
            isNeedUpgradePriority = false;
            string ver = null;
            ArrayList keysList = MapEx.keys2List(serververVer);
            int count = keysList.Count;
            string basePath = CLPathCfg.self.basePath;
            string key = "";
            for (int i = 0; i < count; i++)
            {
                key = keysList[i] as string;

                ver = MapEx.getString(localverVer, key); //实际上这个时间localverVer是空的
                if (ver == null || ver != MapEx.getString(serververVer, key))
                {
                    if (!key.Contains(PStr.b().a(basePath).a("/ui/panel").e())
                        && !key.Contains(PStr.b().a(basePath).a("/ui/cell").e())
                        && !key.Contains(PStr.b().a(basePath).a("/ui/other").e()))
                    {
                        MapEx.set(needUpgradeVerver, key, false);
                    }
                }
            }
            keysList.Clear();
            keysList = null;

            if (needUpgradeVerver.Count > 0)
            {
                if (progressCallback != null)
                {
                    Utl.doCallback(progressCallback, needUpgradeVerver.Count, 0);
                }

                keysList = MapEx.keys2List(needUpgradeVerver);
                count = keysList.Count;
                key = "";
                for (int i = 0; i < count; i++)
                {
                    key = keysList[i] as string;
                    getVerinfor(key, MapEx.getString(serververVer, key));
                }
                keysList.Clear();
                keysList = null;
            }
            else
            {
                loadPriorityVer();
                loadOtherResVer(true);
            }
        }


        //-- 取得版本文件
        static void getVerinfor(string fPath, string verVal)
        {
            //-- 注意是加了版本号的，可以使用cdn
            string url = PStr.b().a(baseUrl).a("/").a(fPath).a(".").a(verVal).e();
            WWWEx.get(url, CLAssetType.bytes,
            (Callback)onGetVerinfor,
            (Callback)onGetVerinfor, fPath, true);
        }

        static void onGetVerinfor(params object[] param)
        {
            byte[] content = param[0] as byte[];
            object orgs = param[1];
            if (content != null)
            {
                string fPath = orgs as string;
                progress = progress + 1;
                MapEx.set(localverVer, fPath, MapEx.getString(serververVer, fPath));

                string fName = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(newestVerPath).a("/").a(fPath).e();
                if (Path.GetFileName(fName) == "priority.ver")
                {
                    //-- 优先更新需要把所有资源更新完后才记录
                    isNeedUpgradePriority = true;
                    serverPriorityVer = CLVerManager.self.toMap(content);
                    CLVerManager.self.localPriorityVer = serverPriorityVer;
                }
                else
                {
                    otherResVerNew = CLVerManager.self.toMap(content);
                    CLVerManager.self.otherResVerNew = otherResVerNew;
                }

                MapEx.set(needUpgradeVerver, fPath, true);

                if (progressCallback != null)
                {
                    Utl.doCallback(progressCallback, needUpgradeVerver.Count, progress);
                }

                //-- if (isFinishAllGet()) then
                if (needUpgradeVerver.Count == progress)
                {
                    if (!isNeedUpgradePriority)
                    {
                        //-- 说明没有优先资源需要更新，可以不做其它处理了
                        //--同步到本地
                        loadPriorityVer();
                        loadOtherResVer(true);
                    }
                    else
                    {
                        checkPriority(); //--处理优先资源更新
                    }
                }
            }
            else
            {
                initFailed();
            }
        }


        static void checkPriority()
        {
            localPriorityVer = new Hashtable();

            progress = 0;
            needUpgradeVerver.Clear();
            needUpgradePrioritis.Clear();
            string ver = null;
            ArrayList keysList = MapEx.keys2List(serverPriorityVer);
            string key = null;
            int count = keysList.Count;
            for (int i = 0; i < count; i++)
            {
                key = keysList[i] as string;
                ver = MapEx.getString(localPriorityVer, key);
                //实际上这个时间localverVer是空的，因此其实就是取得所有优先资源，但是因为了加了版本号，所以可以使用cdn，或者本地缓存什么的
                if (ver == null || ver != MapEx.getString(serverPriorityVer, key))
                {
                    MapEx.set(needUpgradeVerver, key, false);
                    needUpgradePrioritis.Enqueue(key);
                }
            }
            keysList.Clear();
            keysList = null;

            if (needUpgradePrioritis.Count > 0)
            {
                haveUpgrade = true;
                CLVerManager.self.haveUpgrade = true;
                if (progressCallback != null)
                {
                    Utl.doCallback(progressCallback, needUpgradeVerver.Count, 0);
                }
                getPriorityFiles(needUpgradePrioritis.Dequeue() as string);
            }
            else
            {
                //--同步总的版本管理文件到本地
                //MemoryStream ms = new MemoryStream();
                //B2OutputStream.writeMap(ms, localverVer);
                //string vpath = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(mVerverPath).e();
                //FileEx.CreateDirectory(Path.GetDirectoryName(vpath));
                //File.WriteAllBytes(vpath, ms.ToArray());

                loadOtherResVer(true);
            }
        }

        //-- 取得优先更新的资源
        static void getPriorityFiles(string fPath)
        {
            string Url = "";
            string verVal = MapEx.getString(serverPriorityVer, fPath);
            //--把版本号拼在后面
            Url = PStr.begin().a(baseUrl).a("/").a(fPath).a(".").a(verVal).e();
            //-- print("Url=="..Url);

            WWWEx.get(Url, CLAssetType.bytes,
            (Callback)onGetPriorityFiles,
            (Callback)initFailed, fPath, true);

            if (progressCallback != null)
            {
                Utl.doCallback(progressCallback, needUpgradeVerver.Count, progress, WWWEx.getWwwByUrl(Url));
            }
        }

        static void onGetPriorityFiles(params object[] param)
        {
            byte[] content = param[0] as byte[];
            object orgs = param[1];
            if (content == null)
            {
                Utl.doCallback((Callback)initFailed);
                return;
            }

            string fPath = orgs as string;
            progress = progress + 1;
            //缓存起来
            resCache4Webgl[fPath] = content;
            //-- 先把文件放在tmp目录，等全部下载好后再移到正式目录
            //string fName = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(tmpUpgradePirorityPath).a("/").a(fPath).e();
            //FileEx.CreateDirectory(Path.GetDirectoryName(fName));
            //File.WriteAllBytes(fName, content);

            //--同步到本地
            //MapEx.set(localPriorityVer, fPath, MapEx.getString(serverPriorityVer, fPath));
            //MapEx.set(needUpgradeVerver, fPath, true);
            //CLVerManager.self.localPriorityVer = localPriorityVer;
            if (progressCallback != null)
            {
                Utl.doCallback(progressCallback, needUpgradeVerver.Count, progress);
            }

            if (needUpgradePrioritis.Count > 0)
            {
                getPriorityFiles(needUpgradePrioritis.Dequeue() as string);
            }
            else
            {
                //--已经把所有资源取得完成
                //-- 先把文件放在tmp目录，等全部下载好后再移到正式目录
                //ArrayList keysList = MapEx.keys2List(needUpgradeVerver);
                //int count = keysList.Count;
                //string key = null;
                //string fromFile = "";
                //string toFile = "";
                //for (int i = 0; i < count; i++)
                //{
                //    key = keysList[i];
                //    fromFile = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(tmpUpgradePirorityPath).a("/").a(key).e();
                //    toFile = PStr.begin().a(CLPathCfg.persistentDataPath).a("/").a(key).e();
                //    FileEx.CreateDirectory(Path.GetDirectoryName(toFile));
                //    File.Copy(fromFile, toFile, true);
                //}
                //Directory.Delete(PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(tmpUpgradePirorityPath).e(), true);
                //keysList.Clear();
                //keysList = null;

                //--同步优先资源更新的版本管理文件到本地
                //MemoryStream ms = new MemoryStream();
                //B2OutputStream.writeMap(ms, localPriorityVer);
                //string vpath = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(mVerPrioriPath).e();
                //FileEx.CreateDirectory(Path.GetDirectoryName(vpath));
                //File.WriteAllBytes(vpath, ms.ToArray());

                //--同步总的版本管理文件到本地
                //ms = new MemoryStream();
                //B2OutputStream.writeMap(ms, localverVer);
                //vpath = PStr.b().a(CLPathCfg.persistentDataPath).a("/").a(mVerverPath).e();
                //FileEx.CreateDirectory(Path.GetDirectoryName(vpath));
                //File.WriteAllBytes(vpath, ms.ToArray());

                loadOtherResVer(true);
            }
        }

        static void loadPriorityVer()
        {
            localPriorityVer = serverPriorityVer;
            CLVerManager.self.localPriorityVer = localPriorityVer;
        }

        static void loadOtherResVer(bool sucessProcUpgrade)
        {
            isSucessUpgraded = sucessProcUpgrade;
            otherResVerOld = otherResVerNew;
            Utl.doCallback(onFinishInit, isSucessUpgraded);
        }

        static void initFailed(params object[] param)
        {
            if (progressCallback != null)
            {
                Utl.doCallback(progressCallback, needUpgradeVerver.Count, progress, null);
            }
            loadPriorityVer();
            loadOtherResVer(false);
        }

    }
}