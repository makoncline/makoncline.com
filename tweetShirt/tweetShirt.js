
window.onload = function () {
	//assign the button from html to variable
	var button = document.getElementById("previewButton");
	//call a function when a button is pressed
	button.onclick = previewHandler;
};

//This is called when the button is pressed
function previewHandler (){
	//assign the canvas to a variable
	var canvas = document.getElementById("tshirtCanvas");
	//give the canvas element a context to draw on
	var context = canvas.getContext("2d");
	//cover up anything that may already be on the canvas by filling it with the background color
	fillBackgroundColor(canvas, context);
	//pulls the shape selection from the html and names it select object
	var selectObj = document.getElementById("shape");
	//gets the index of the choice that is selected by user and sets it to index
	var index = selectObj.selectedIndex;
	//gets the value of the choice in that index
	var shape = selectObj[index].value;

	if (shape == "squares"){
		//put 20 squares on the tshirtCanvas`
		for (var squares = 0; squares < 20; squares++) {
			drawSquare(canvas, context);
		}
	}  else if (shape == "circles"){
		//put 20 circles on the tshirtCanvas`
		for (var circles = 0; circles < 20; circles++) {
			drawCircle(canvas, context);
		}
	}
	drawText(canvas, context);
	drawBird(canvas, context);
}

function fillBackgroundColor(canvas, context) {
	var selectObj = document.getElementById("backgroundColor");
	var index = selectObj.selectedIndex;
	var bgColor = selectObj.options[index].value;
	context.fillStyle = bgColor;
	context.fillRect(0, 0, canvas.width, canvas.height);
	
}

function drawSquare(canvas, context){
	//get random values for the position and sixe of square
	var w = Math.floor(Math.random() * 40);
	var x = Math.floor(Math.random() *  canvas.width);
	var y = Math.floor(Math.random() * canvas.height);

	//give the square some color
	context.fillStyle = "lightblue";
	//draw the square
	context.fillRect(x,y,w,w);

}

function drawCircle(canvas, context) {
	var r = Math.floor(Math.random() * 40);
	var x = Math.floor(Math.random() *  canvas.width);
	var y = Math.floor(Math.random() * canvas.height);
	context.beginPath();
	context.arc(x, y, r, 0, degreesToRadians(360), true);
	context.fillStyle = "lightblue";
	context.fill();

}

function degreesToRadians (degrees){
	return (degrees * Math.PI)/180;
}

function updateTweets(tweets) {
    var tweetsSelection = document.getElementById("tweets");
    
    for (var i = 0, tweetsCount = tweets.length; i < tweetsCount; i++) {
        var tweet = tweets[i];
        
        var option = document.createElement("option");
        option.text = tweet.text;
        
        option.value = tweet.text.replace("\"", "'");
        
        tweetsSelection.options.add(option);
    }
    tweetsSelection.selectedIndex = 0;
}

function drawText(canvas, context) {
	var selectObj = document.getElementById("foregroundColor");
	var index = selectObj.selectedIndex;
	var fgColor = selectObj[index].value;

	context.fillStyle = fgColor;
	context.font = "bold 1em sans-serif";
	context.textAlign = "left";
	context.fillText("I saw this tweet", 20, 40);

	var tweetsSelection = document.getElementById("tweets");
	var tweetIndex = tweetsSelection.selectedIndex;
	var tweet = tweets[tweetIndex].value;
	context.font  = "bold 1.2em sans-serif";
	context.textAlign = "left";
	context.fillText(tweet, 30, 100);

	context.font  = "bold 1em sans-serif";
	context.textAlign = "right";
	context.fillText("and all i got was this lousy t-shirt!", canvas.width - 20, canvas.height - 40);

}

function drawBird(canvas, context) {
	var twitterBird = new Image();
	twitterBird.src = "twitterBird.png";
	twitterBird.onload = function(){
		context.drawImage(twitterBird, 20, 120, 70, 70);
	}
}
