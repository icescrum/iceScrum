package org.icescrum.web

/**
 * Created by vbarrier on 02/10/2014.
 */
public class FileUploadInfoStorage {

    private static FileUploadInfoStorage sInstance
    private HashMap<String, FileUploadInfo> mMap = new HashMap<String, FileUploadInfo>()

    private FileUploadInfoStorage() {}


    public static synchronized FileUploadInfoStorage getInstance() {
        if (sInstance == null) {
            sInstance = new FileUploadInfoStorage()
        }
        return sInstance
    }


    public synchronized FileUploadInfo get(Map properties) {

        FileUploadInfo info = mMap.get(properties.identifier)

        if (info == null) {
            info = new FileUploadInfo(properties)
            mMap.put(properties.identifier, info)
        }
        return info
    }

    public void remove(FileUploadInfo info) {
        new File(info.filePath).delete()
        mMap.remove(info.identifier)
    }
}
