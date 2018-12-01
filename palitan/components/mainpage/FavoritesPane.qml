import QtQuick 2.9
import QtQuick.Controls 2.2
import "../mainpage"
import "../mainpage/favoritespane"
import "../common"
import "../../library/currencies.js" as Currencies


Pane {
	id: favoritespPane
	
	readonly property int maxSorting: 2
	property int sorting: settings.favoritesSorting
	property string inputTextValue
	
	onSortingChanged:{
		sortFavorites()
	}
	
	//~ function getIndex(target){
		//~ var targetKeys = Object.keys(target);
		//~ var index = settings.favorites.findIndex(function(entry) {
		    //~ var keys = Object.keys(entry);
		    //~ return keys.length == targetKeys.length && keys.every(function(key) {
		        //~ return target.hasOwnProperty(key) && entry[key] === target[key];
		    //~ });
		//~ });
		//~ return index
	//~ }
	
	function getIndex(target){
		var targetKeys = Object.keys(target);
		var index = settings.favorites.findIndex(function(entry) {
		    var keys = Object.keys(entry);
		    return keys.every(function(key) {
				if(key !== "sequence"){
					return target.hasOwnProperty(key) && entry[key] === target[key];
				}else{
					return true
				}
		    });
		});
		return index
	}
	
	function addFavorite(code1, code2){
		var comb1 = {"base": code1, "destination": code2}
		var comb2 = {"base": code2, "destination": code1}
		
		var findInt = getIndex(comb1);
		var findInt2 = getIndex(comb2);
		
		if(findInt === -1 && findInt2 === -1){
			var temp = settings.favorites.slice()
			
			comb1.sequence = temp.length
			temp.push(comb1)
			settings.favorites = temp.slice()
			sortFavorites()
			return true
		}else{
			return false
		}
	}
	
	function showAddDialog(isBottom){
		if(isBottom){
			addDialog.openBottom()
		}else{
			addDialog.openNormal()
		}
	}
	
	function removeFavorites(index){
		var temp = settings.favorites.slice()
			
		temp.splice(index, 1)
		settings.favorites = temp.slice()
	}
	
	function confirmDelete(index){
		listView.currentIndex = index
		deleteConfirmationDialog.openDialog()
	}
	
	function setConvertPane(code1, code2){
		convertPane.setCurrencies(code1, code2)
		
		//Switch to Convert pane
		mainPage.goTo("CONVERT")
	}
	
	function toggelSorting(){
		var newSorting
		
		if(sorting < maxSorting){
			newSorting = sorting + 1
		}else{
			newSorting = 0
		}
		
		settings.favoritesSorting = newSorting
	}
	
	function sortFavorites(){
		var compareFunction 
		var temp = settings.favorites.slice()
		
		switch(sorting){
			// Default based on sequence of adding
			case 0:
				compareFunction = function(a, b){
									return a.sequence-b.sequence
								}
			break
			
			// Alphabetical Ascending
			case 1:
				compareFunction = function(a, b){
									return ('' + a.base).localeCompare(b.base);
								}
			break
			
			// Alphabetical Descending
			case 2:
				compareFunction = function(a, b){
									return ('' + b.base).localeCompare(a.base);
								}
			break
			
		}
		
							
		settings.favorites = temp.sort(compareFunction).slice()
	}
	
	Label{
		id: emptyLabel
		
		visible: !listView.visible
		text: i18n.tr("You don't have any favorites")
		font.pixelSize: 15
		anchors.centerIn: parent
		horizontalAlignment: Text.AlignHCenter
		z: 1
	}
	
	ListView {
		id: listView
		
		visible: model.length > 0
		snapMode: ListView.SnapToItem 
		anchors{
			top: parent.top
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			//~ bottomMargin: 10
		}
		
		spacing: 10
		model: settings.favorites
		delegate: FavoriteDelegate{
			currency1: Currencies.money(mainModels.currencyModel2.getItem(modelData.base,"code"), baseValue)
			currency2: Currencies.money(mainModels.currencyModel2.getItem(modelData.destination,"code"), destinationValue)
			baseValue: inputTextValue ? inputTextValue : 0 //valueTextField.text ? valueTextField.text : 0
			destinationValue: inputTextValue ? inputTextValue : 0 //valueTextField.text ? valueTextField.text : 0
		}
	}
	
	DeleteDialog{
		id: deleteConfirmationDialog
	}
	
	AddDialog{
		id: addDialog
	}
}