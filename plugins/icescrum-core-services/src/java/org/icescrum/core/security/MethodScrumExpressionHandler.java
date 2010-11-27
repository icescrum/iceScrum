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
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */


package org.icescrum.core.security;

import org.aopalliance.intercept.MethodInvocation;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.icescrum.core.services.SecurityService;
import org.springframework.core.LocalVariableTableParameterNameDiscoverer;
import org.springframework.core.ParameterNameDiscoverer;
import org.springframework.expression.EvaluationContext;
import org.springframework.expression.Expression;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.security.access.PermissionEvaluator;
import org.springframework.security.access.expression.ExpressionUtils;
import org.springframework.security.access.expression.method.MethodSecurityExpressionHandler;
import org.springframework.security.access.hierarchicalroles.RoleHierarchy;
import org.springframework.security.authentication.AuthenticationTrustResolver;
import org.springframework.security.authentication.AuthenticationTrustResolverImpl;
import org.springframework.security.core.Authentication;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * The standard implementation of <tt>SecurityExpressionHandler</tt>.
 * <p/>
 * A single instance should usually be shared amongst the beans that require expression support.
 *
 * @author Luke Taylor
 * @since 3.0
 */
public class MethodScrumExpressionHandler implements MethodSecurityExpressionHandler {

    protected final Log logger = LogFactory.getLog(getClass());

    private ParameterNameDiscoverer parameterNameDiscoverer = new LocalVariableTableParameterNameDiscoverer();
    private PermissionEvaluator permissionEvaluator;
    private AuthenticationTrustResolver trustResolver = new AuthenticationTrustResolverImpl();
    private ExpressionParser expressionParser = new SpelExpressionParser();
    private RoleHierarchy roleHierarchy;
    private SecurityService securityService;

    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }

    public MethodScrumExpressionHandler() {
    }

    /**
     */
    public EvaluationContext createEvaluationContext(Authentication auth, MethodInvocation mi) {
        MethodScrumEvaluationContext ctx = new MethodScrumEvaluationContext(auth, mi, parameterNameDiscoverer);
        MethodScrumExpressionRoot root = new MethodScrumExpressionRoot(auth);
        root.setTrustResolver(trustResolver);
        root.setPermissionEvaluator(permissionEvaluator);
        root.setRoleHierarchy(roleHierarchy);
        root.setSecurityService(securityService);
        ctx.setRootObject(root);

        return ctx;
    }

    @SuppressWarnings("unchecked")
    public Object filter(Object filterTarget, Expression filterExpression, EvaluationContext ctx) {
        MethodScrumExpressionRoot rootObject = (MethodScrumExpressionRoot) ctx.getRootObject().getValue();
        List retainList;

        if (logger.isDebugEnabled()) {
            logger.debug("Filtering with expression: " + filterExpression.getExpressionString());
        }

        if (filterTarget instanceof Collection) {
            Collection collection = (Collection) filterTarget;
            retainList = new ArrayList(collection.size());

            if (logger.isDebugEnabled()) {
                logger.debug("Filtering collection with " + collection.size() + " elements");
            }
            for (Object filterObject : (Collection) filterTarget) {
                rootObject.setFilterObject(filterObject);

                if (ExpressionUtils.evaluateAsBoolean(filterExpression, ctx)) {
                    retainList.add(filterObject);
                }
            }

            if (logger.isDebugEnabled()) {
                logger.debug("Retaining elements: " + retainList);
            }

            collection.clear();
            collection.addAll(retainList);

            return filterTarget;
        }

        if (filterTarget.getClass().isArray()) {
            Object[] array = (Object[]) filterTarget;
            retainList = new ArrayList(array.length);

            if (logger.isDebugEnabled()) {
                logger.debug("Filtering collection with " + array.length + " elements");
            }

            for (int i = 0; i < array.length; i++) {
                rootObject.setFilterObject(array[i]);

                if (ExpressionUtils.evaluateAsBoolean(filterExpression, ctx)) {
                    retainList.add(array[i]);
                }
            }

            if (logger.isDebugEnabled()) {
                logger.debug("Retaining elements: " + retainList);
            }

            Object[] filtered = (Object[]) Array.newInstance(filterTarget.getClass().getComponentType(),
                    retainList.size());
            for (int i = 0; i < retainList.size(); i++) {
                filtered[i] = retainList.get(i);
            }

            return filtered;
        }

        throw new IllegalArgumentException("Filter target must be a collection or array type, but was " + filterTarget);
    }

    public ExpressionParser getExpressionParser() {
        return expressionParser;
    }

    public void setParameterNameDiscoverer(ParameterNameDiscoverer parameterNameDiscoverer) {
        this.parameterNameDiscoverer = parameterNameDiscoverer;
    }

    public void setPermissionEvaluator(PermissionEvaluator permissionEvaluator) {
        this.permissionEvaluator = permissionEvaluator;
    }

    public void setTrustResolver(AuthenticationTrustResolver trustResolver) {
        this.trustResolver = trustResolver;
    }

    public void setReturnObject(Object returnObject, EvaluationContext ctx) {
        ((MethodScrumExpressionRoot) ctx.getRootObject().getValue()).setReturnObject(returnObject);
    }

    public void setRoleHierarchy(RoleHierarchy roleHierarchy) {
        this.roleHierarchy = roleHierarchy;
    }
}

