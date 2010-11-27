import grails.plugin.fluxiable.Fluxiable
import grails.plugin.fluxiable.ActivityLink
import grails.util.GrailsNameUtils
import grails.plugin.fluxiable.ActivityException
import grails.plugin.fluxiable.Activity

class FluxiableGrailsPlugin {
  def version = "0.1"
  // the version or versions of Grails the plugin is designed for
  def grailsVersion = "1.3 > *"
  // the other plugins this plugin depends on
  def dependsOn = [hibernate: "1.3 > *"]
  // resources that are excluded from plugin packaging
  def pluginExcludes = [
          "grails-app/views/error.gsp"
  ]
  def author = "Stephane Maldini"
  def authorEmail = "smaldini@doc4web.com"
  def title = "Fluxiable Plugin"
  def description = '''\\
Inspired by Commentable plugin, this one allows you to display domain activity in a generic manner.
'''

  // URL to the plugin's documentation
  def documentation = "http://grails.org/fluxiable"

  def doWithSpring = {
    def config = application.config

  }
  def doWithDynamicMethods = { ctx ->
    for (domainClass in application.domainClasses) {
      if (Fluxiable.class.isAssignableFrom(domainClass.clazz)) {
        domainClass.clazz.metaClass {
          'static' {
            getRecentActivities {link=false->
              def clazz = delegate
              ActivityLink.getRecentActivities(clazz,link).list()
            }
          }

          addActivity { poster, String code, String cachedLabel, String cachedDesc = null ->
            if (delegate.id == null) throw new ActivityException("You must save the entity [${delegate}] before calling addActivity")

            def posterClass = poster.class.name
            def i = posterClass.indexOf('_$$_javassist')
            if (i > -1)
              posterClass = posterClass[0..i - 1]

            def c = new Activity(code: code, cachedLabel: cachedLabel, posterId: poster.id, posterClass: posterClass, cachedId: delegate.id,
                    cachedDescription: cachedDesc)
            if (!c.validate()) {
              throw new ActivityException("Cannot create activity for arguments [$poster, $code, $cachedLabel], they are invalid.")
            }
            c.save()

            def delegateClass = delegate.class.name
            i = delegateClass.indexOf('_$$_javassist')
            if (i > -1) delegateClass = delegateClass[0..i - 1]

            def link = new ActivityLink(activity: c, activityRef: delegate.id, type: GrailsNameUtils.getPropertyName(delegateClass))
            link.save()
            try {
              delegate.onAddActivity(c)
            } catch (MissingMethodException e) {}
            return delegate
          }

          getActivities = {link=false->
            ActivityLink.getActivities(delegate,link).list()
          }

          getTotalActivities = {->
            ActivityLink.getTotalActivities(delegate).list()[0]
          }

          removeActivity { Activity a ->
            a.delete()
          }

          removeActivity { Long id ->
            def c = Activity.load(id)
            if (c) removeActivity(c)
          }
        }
      }
    }
  }

}
