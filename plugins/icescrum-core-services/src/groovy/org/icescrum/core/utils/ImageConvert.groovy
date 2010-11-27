/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */


package org.icescrum.core.utils
import com.sun.media.jai.codec.ImageEncoder
import javax.media.jai.RenderedOp
import javax.media.jai.JAI
import java.awt.image.ColorConvertOp
import java.awt.color.ColorSpace
import java.awt.image.BufferedImage
import com.sun.media.jai.codec.JPEGEncodeParam
import com.sun.media.jai.codec.ImageCodec
import com.sun.media.jai.codec.PNGEncodeParam
import java.awt.image.BufferedImage

class ImageConvert {
  static void convertToPNG(String inputFile, String outputFile)
  {
      OutputStream ios
      try
      {
          RenderedOp src = JAI.create("fileload", inputFile)
          BufferedImage dst = new BufferedImage(src.width, src.height, BufferedImage.TYPE_3BYTE_BGR)
          ios = new BufferedOutputStream(new FileOutputStream(new File(outputFile)))
          ImageEncoder enc = ImageCodec.createImageEncoder("png", ios, PNGEncodeParam.getDefaultEncodeParam(dst))
          //Apply the color filter and return the result.
          ColorConvertOp filterObj = new ColorConvertOp(ColorSpace.getInstance(ColorSpace.CS_sRGB), null)
          filterObj.filter(src.getAsBufferedImage(), dst)
          enc.encode(dst)
      }
      catch (Exception e)
      {
          throw new RuntimeException(e)
      }
      finally
      {
          ios.close()
      }
  }
}
