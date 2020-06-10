import org.codehaus.groovy.grails.commons.UrlMappingsArtefactHandler

includeTargets << grailsScript("_GrailsBootstrap")

target(urlMappingsReport: "Produces a URL mappings report for the current Grails application") {
    depends(classpath, compile, loadApp)
    def mappings = grailsApp.getArtefacts(UrlMappingsArtefactHandler.TYPE)
    def evaluator = classLoader.loadClass("org.codehaus.groovy.grails.web.mapping.DefaultUrlMappingEvaluator").newInstance(classLoader.loadClass('org.springframework.mock.web.MockServletContext').newInstance())
    def allMappings = []
    for (m in mappings) {
        List grailsClassMappings
        if (Script.isAssignableFrom(m.getClazz())) {
            grailsClassMappings = evaluator.evaluateMappings(m.getClazz())
        } else {
            grailsClassMappings = evaluator.evaluateMappings(m.getMappingsClosure())
        }
        allMappings.addAll(grailsClassMappings)
    }
    def renderer = classLoader.loadClass("org.icescrum.web.OpenAPIUrlMappingsRenderer").newInstance()
    renderer.render(allMappings)
}

setDefaultTarget(urlMappingsReport)
