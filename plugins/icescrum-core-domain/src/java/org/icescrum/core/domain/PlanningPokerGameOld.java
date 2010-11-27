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
 * Manuarii Stein (manuarii.stein@icescrum.com)
 */


package org.icescrum.core.domain;import java.util.ArrayList;
import java.util.List;


public class PlanningPokerGameOld {

	static final public Integer INTEGER_SUITE = 0;
	static final public Integer FIBO_SUITE = 1;
	static final public int SPECIALCARD_UNKNOW_NUMBER = -2;
	static final public int SPECIALCARD_HALF_NUMBER = -3;

	static public List<PlanningPokerCard> get(int type,int max){
		List<PlanningPokerCard> suite = new ArrayList<PlanningPokerCard>();
//		suite.add(new PlanningPokerCard(SPECIALCARD_UNKNOW_NUMBER));
//		suite.add(new PlanningPokerCard(SPECIALCARD_HALF_NUMBER));
		int i;
		if(type == INTEGER_SUITE){
			for(i = 0;i<=max;i++){
				suite.add(new PlanningPokerCard(i));
			}
		}else if(type == FIBO_SUITE)
		{
			suite.add(new PlanningPokerCard(0));
			suite.add(new PlanningPokerCard(1));
			suite.add(new PlanningPokerCard(2));
			suite.add(new PlanningPokerCard(3));
			suite.add(new PlanningPokerCard(5));
			suite.add(new PlanningPokerCard(8));
			suite.add(new PlanningPokerCard(13));
			suite.add(new PlanningPokerCard(21));
			suite.add(new PlanningPokerCard(34));
		}
		
		return suite;
	}
}
