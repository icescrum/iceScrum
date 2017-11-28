/*
 * Copyright (c) 2017 Kagilum SAS
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

class PortfolioUrlMappings {

    static mappings = {
        "/f/$portfolio/" {
            controller = 'scrumOS'
            action = 'index'
            constraints {
                portfolio(matches: /[0-9A-Z]*/)
            }
        }
        // Window in portfolio workspace
        "/f/$portfolio/ui/window/$windowDefinitionId" {
            controller = 'window'
            action = 'show'
            constraints {
                windowDefinitionId(matches: /[a-zA-Z]*/)
                portfolio(matches: /[0-9A-Z]*/)
            }
        }
        // Window settings in portfolio workspace
        "/f/$portfolio/ui/window/$windowDefinitionId/settings" {
            controller = 'window'
            action = [GET: "settings", POST: "updateSettings"]
            constraints {
                windowDefinitionId(matches: /[a-zA-Z]*/)
                portfolio(matches: /[0-9A-Z]*/)
            }
        }
    }
}