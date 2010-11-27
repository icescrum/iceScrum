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

import org.icescrum.core.domain.Product;
import org.icescrum.core.domain.Team;
import org.icescrum.core.services.SecurityService;
import org.springframework.security.access.PermissionEvaluator;
import org.springframework.security.access.expression.SecurityExpressionRoot;
import org.springframework.security.core.Authentication;

import java.io.Serializable;

public class MethodScrumExpressionRoot extends SecurityExpressionRoot implements ScrumExpressionRoot {

    private SecurityService securityService;

    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }

    public MethodScrumExpressionRoot(Authentication a) {
        super(a);
    }


    private PermissionEvaluator permissionEvaluator;
    private Object filterObject;
    private Object returnObject;
    public final String read = "read";
    public final String write = "write";
    public final String create = "create";
    public final String delete = "delete";
    public final String admin = "administration";


    public boolean hasPermission(Object target, Object permission) {
        return permissionEvaluator.hasPermission(authentication, target, permission);
    }

    public boolean hasPermission(Object targetId, String targetType, Object permission) {
        return permissionEvaluator.hasPermission(authentication, (Serializable) targetId, targetType, permission);
    }

    public void setFilterObject(Object filterObject) {
        this.filterObject = filterObject;
    }

    public Object getFilterObject() {
        return filterObject;
    }

    public void setReturnObject(Object returnObject) {
        this.returnObject = returnObject;
    }

    public Object getReturnObject() {
        return returnObject;
    }

    public void setPermissionEvaluator(PermissionEvaluator permissionEvaluator) {
        this.permissionEvaluator = permissionEvaluator;
    }

    public boolean inProduct(Product p) {
        return securityService.inProduct(p, super.authentication);
    }

    public boolean inProduct(long p) {
        return securityService.inProduct(p, super.authentication);
    }

    public boolean inProduct() {
        return inProduct(null);
    }

    public boolean inTeam(Team t) {
        return securityService.inTeam(t, super.authentication);
    }

    public boolean inTeam(long t) {
        return securityService.inTeam(t, super.authentication);
    }

    public boolean inTeam() {
        return inTeam(null);
    }


    public boolean productOwner() {
        return securityService.productOwner(null, super.authentication);
    }

    public boolean productOwner(long p) {
        return securityService.productOwner(p, super.authentication);
    }

    public boolean productOwner(Product p) {
        return securityService.productOwner(p, super.authentication);
    }

    public boolean teamMember() {
        return securityService.teamMember(null, super.authentication);
    }

    public boolean teamMember(long t) {
        return securityService.teamMember(t, super.authentication);
    }

    public boolean teamMember(Team t) {
        return securityService.teamMember(t, super.authentication);
    }

    public boolean scrumMaster() {
        return securityService.scrumMaster(null, super.authentication);
    }

    public boolean scrumMaster(long t) {
        return securityService.scrumMaster(t, super.authentication);
    }

    public boolean scrumMaster(Team t) {
        return securityService.scrumMaster(t, super.authentication);
    }

    public boolean stakeHolder() {
        return securityService.stakeHolder(null, super.authentication);
    }

    public boolean stakeHolder(long p) {
        return securityService.stakeHolder(p, super.authentication);
    }

    public boolean stakeHolder(Product p) {
        return securityService.stakeHolder(p, super.authentication);
    }

    public boolean owner() {
        return securityService.owner(null, super.authentication);
    }


    public boolean owner(Object o) {
        return securityService.owner(o, super.authentication);
    }
}
