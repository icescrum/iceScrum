/*
 * Copyright (c) 2014 Kagilum SAS.
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
services.factory( 'AcceptanceTest', [ 'Resource', function( $resource ) {
    return $resource( 'acceptanceTest/:type/:storyId',
        { id: '@id' } ,
        {
            query:           {method:'GET', isArray:true, cache: true},
            activities:      {method:'GET', isArray:true, params:{action:'activities'}}
        });
}]);

services.service("AcceptanceTestService", ['AcceptanceTest', function(AcceptanceTest) {
    this.save = function(acceptanceTest, story){
        acceptanceTest.class = 'acceptanceTest';
        acceptanceTest.parentStory = {id:story.id};
        AcceptanceTest.save(acceptanceTest, function(acceptanceTest){
            story.acceptanceTests.push(acceptanceTest);
            story.acceptanceTests_count += 1;
        });
    };
    this['delete'] = function(acceptanceTest, story){
        acceptanceTest.$delete(function(){
            if (story){
                var index = story.acceptanceTests.indexOf(acceptanceTest);
                if (index != -1){
                    story.acceptanceTests.splice(index, 1);
                    story.acceptanceTests_count -= 1;
                }
            }
        });
    };
    this.list = function(story){
        AcceptanceTest.query({ storyId: story.id, type: 'story' }, function(data) {
            story.acceptanceTests = data;
        });
    }
}]);