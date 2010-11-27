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


package org.icescrum.core.domain;

public class PlanningPokerCard {

	private int cardValue;
	
	public PlanningPokerCard(int cardValue) {
		this.cardValue = cardValue;
	}

	public int getCardValue() {
		return cardValue;
	}

	public void setCardValue(int cardValue) {
		this.cardValue = cardValue;
	}
	
	public String getDisplay(){
		if(cardValue == PlanningPokerGameOld.SPECIALCARD_HALF_NUMBER)
			return "1/2";
		else if(cardValue <= PlanningPokerGameOld.SPECIALCARD_UNKNOW_NUMBER)
			return "?";
		else 
			return String.valueOf(this.cardValue);
	}
	

}
