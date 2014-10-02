package org.icescrum.web

public class FileUploadInfo {

    int      chunkSize
    long     totalSize
    String   identifier
    String   filename
    String   relativePath
    HashSet<ChunkNumber> uploadedChunks = new HashSet<ChunkNumber>()
    String filePath

    public static class ChunkNumber {
        int number;

        public ChunkNumber(int number) {
            this.number = number
        }

        @Override
        boolean equals(Object obj) {
            return obj instanceof ChunkNumber ? ((ChunkNumber)obj).number == this.number : false
        }

        @Override
        int hashCode() {
            return number
        }
    }

    boolean valid(){
        return !(chunkSize < 0 || totalSize < 0 || identifier.isEmpty() || filename.isEmpty() || relativePath.isEmpty())
    }
    public boolean checkIfUploadFinished() {
        //check if upload finished
        int count = (int) Math.ceil(((double) totalSize) / ((double) chunkSize));
        for(int i = 1; i < count + 1; i ++) {
            if (!uploadedChunks.contains(new ChunkNumber(i))) {
                return false
            }
        }
        //Upload finished, change filename.
        File file = new File(filePath)
        String new_path = file.absolutePath.substring(0, file.absolutePath.length() - ".temp".length())
        file.renameTo(new File(new_path))
        filePath = new_path
        return true
    }
}