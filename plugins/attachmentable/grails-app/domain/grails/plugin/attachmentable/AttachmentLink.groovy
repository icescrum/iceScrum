package grails.plugin.attachmentable
import grails.util.GrailsNameUtils

class AttachmentLink {

    Long attachmentRef
    String attachmentRefClass
    String type

    static belongsTo = [attachment: Attachment]

    static constraints = {
        attachmentRef min:0L
        attachmentRefClass blank:false
		type blank:false
    }

    static mapping = {
      table 'attachmentable_attachmentlink'
      cache true
    }

    static namedQueries = {
      getAttachments {instance ->
        projections {
          property "attachment"
        }
        eq "attachmentRef", instance?.id
        eq 'type', GrailsNameUtils.getPropertyName(instance.class)
      }

      getTotalAttachments {instance ->
        projections {
          rowCount()
        }
        eq "attachmentRef", instance?.id
        eq 'type', GrailsNameUtils.getPropertyName(instance.class)
      }
    }
}