import org.icescrum.atmosphere.IceScrumMeteorHandler

defaultMapping = "/stream/app/*"

servlets = [
        MeteorServletDefault: [
                className : "org.icescrum.atmosphere.IceScrumMeteorServlet",
                mapping   : "/stream/app/*",
                handler   : IceScrumMeteorHandler,
                initParams: [
                        "org.atmosphere.cpr.AtmosphereFramework.analytics"                           : false,
                        "org.atmosphere.cpr.broadcasterClass"                                        : "org.icescrum.atmosphere.IceScrumBroadcaster"
                ]
        ]
]