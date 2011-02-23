function Init(){
	this.q_num = 1;
	this.tally = 0;
	this.total = null;
	this.current_q = null;
	this.next_q = null;
	this.interval = null;
	this.PostSetofPlayers();
	this.scoreArr = [];
	this.scoreTimeStart = new Date();
}

Init.prototype = {
	
	PostSetofPlayers: function(){
		var that = this;
		$.ajax({ url: "http://localhost:3000/x_players", 
				context: document.body, 
				type: "POST",
				success: function(data){ if(data) { that.buildJSONResults(data); } return; },
				failure: function(){ alert("Something went wrong..."); return; }
		},"json");
	},
	
	checkTimer: function(){
		var that = this;
		var ih = this.timer.innerHTML;
		var interval = setInterval(function(){
			if(that.timer)
			{
				ih = that.timer.innerHTML;
				if(ih == "0"){
					that.removeClicks();
					that.timer.parentNode.removeChild(that.timer);
					that.timer = null;
					that.nextQuestion(that.current_q,that.next_q);
				}
			}
		},10);
	},
	
	addTimer: function(){
		var timer = new Timer();
		var ele = timer.init();
		document.body.appendChild(ele);
		timer.startTimer();
		return ele;
	},
	
	buildJSONResults: function(obj){
		this.total = obj["total"];
		var rand = -1;
		var html = "";
		var display = "";
		var base = "";
		var choice = "";
		var team = "";
		for(var i=0;i<this.total;i++){
			base = obj["results"][i];
			html += "<div class=\"question\""+display+"><h1>What team does <span class=\"player\">"+base["name"]+"</span> play for?</h1>";
			for(var j=0;j<4;j++){
				choice = base["choices"][j];
				team = (choice["shortName"] ? choice["shortName"] : choice["team"]);
				html += "<section"+this.correct(base["team"],choice["team"])+" style=\"background:-webkit-gradient(linear, 70% 0%, 100% 0%, from(#FFFFFF), to(#DDDDDD));\"><span style=\"background-image:url(images/team_logos/"+choice["team"].replace(/\s/g,"")+".png);background-position:"+choice["backgroundPosition"]+";\" class=\"bg\"></span><span class=\"team\">"+team+"</span><span class=\"city\">"+choice["city"]+"</span></section>";
			}
			html += "</div>";	
			display = "style=\"display:none;\"";
		}
		var questions = document.createElement("div");
		questions.id = "questions";
		questions.innerHTML = (html + "<footer><span class=\"right\">"+this.tally+"</span> / <span class=\"total\">"+this.total+"</span><br/></footer>");
		document.body.appendChild(questions);
		this.current_q = questions.firstChild;
		this.next_q = this.current_q.nextSibling;
		this.calculateQuestions();
		this.resetTimer();
		this.checkTimer();
	},
	
	correct: function(team1,team2){
		if(team1 == team2)
			return " correct=\"true\"";
		return "";
	},
	
	calculateQuestions: function(){
		var that = this;
		var divs = document.getElementsByTagName("div");
		var h1 = "";
		var sections = "";
		var base = "";
		var team_base = "";
		for(var i=0;i<divs.length;i++){
			base = divs[i];
			if(base.className == "question"){
				sections = base.getElementsByTagName("section");
				for(var j=0;j<sections.length;j++){
					team_base = sections[j];
					$(team_base).bind("click",function(e){ that.checkAnswer(e) });
				}
			}
		}
	},
	
	removeClicks: function(){
		var sections = this.current_q.getElementsByTagName("section");
		for(var j=0;j<sections.length;j++){
			$(sections[j]).unbind();
		}
	},

	checkAnswer: function(e){
		this.removeClicks();
		var that = this;
		var target = e.target;
		if(target.tagName != "SECTION") target = target.parentNode;
		var parent = target.parentNode;
		this.clearSelected(parent);
		var answer = this.changeBgColor(target,target.getAttribute("correct"));
		if(answer) {
			this.tally++;
			this.addToScore();
		}
		setTimeout(function(){ that.nextQuestion(parent,parent.nextSibling); },500);
	},
	
	addToScore: function(){
		var footer = document.getElementsByTagName("footer")[0];
		footer.firstChild.innerHTML = this.tally;
	},

	changeBgColor: function(ele,correct){
		var parent = ele.parentNode;
		if(correct){ 
			ele.style.cssText = "background:-webkit-gradient(linear, 80% 0%, 100% 0%, from(#FFFFFF), to(#00DD00));";
			parent.setAttribute("selected","true");
			this.scoreArr.push(this.calculateScore(new Date()));
			return true;
		} else { 
			ele.style.cssText = "background:-webkit-gradient(linear, 80% 0%, 100% 0%, from(#FFFFFF), to(#DD0000));";
			parent.setAttribute("selected","true");
			return false;
		}
	},
	
	calculateScore: function(date){
		if(date) return 5000+(this.scoreTimeStart.getTime() - date.getTime());
		return 1;
	},	

	clearSelected: function(parent){
		var sections = parent.getElementsByTagName("section");
		for(var i=0;i<sections.length;i++){
			sections[i].style.cssText = "background:-webkit-gradient(linear, 70% 0%, 100% 0%, from(#FFFFFF), to(#DDDDDD));";
		}
	},

	nextQuestion: function(current,next){
		if(!current || !next) return;
		$(current).fadeOut(400);
		if(this.q_num == this.total) { 
			this.killTimer();
			this.finalResults();
			return;
		}
		$(next).fadeIn(400);
		this.q_num++;
		this.current_q = this.next_q;
		this.next_q = this.current_q.nextSibling;
		this.resetTimer();
		this.scoreTimeStart = new Date();
	},
	
	resetTimer: function(){
		this.killTimer();
		this.timer = this.addTimer();
	},
	
	killTimer: function(){
		var timer = document.getElementById("timer");
		if(timer) timer.parentNode.removeChild(timer);
		this.timer = null;
		return;
	},
	
	addScoreTotal: function(){
		if(!this.scoreArr) return 0;
		var sum = 0;
		for(var i=0;i<this.scoreArr.length;i++){
			sum += this.scoreArr[i];
		}
		return sum;
	},
	
	sendStats: function(stats){
		var that = this;
		$.ajax({ url: "http://localhost:3000/save_stats", 
				 context: document.body, 
				 data: { "score":stats["score"], "name":stats["user"].value, "total":stats["total"] },
				 type: "POST",
				 success: function(data){ if(data) { console.log("saved"); } return; },
				 failure: function(){ alert("Something went wrong..."); return; }
		},"json");
	},

	finalResults: function(){
		var that = this;
		var score = this.addScoreTotal();
		var questions = document.getElementById("questions");
		var div = document.createElement("div");
		div.className = "results";
		var html = "<div class=\"totalRight\">You got <span class=\"right\">"+this.tally+"</span> out of <span class=\"total\">"+this.total+"</span> correct.</div><div class=\"score\">You scored <strong>"+score+"</strong> points.</div>";
		html += "<div class=\"submitScore\"><h2>Submit your score.</h2><div class=\"name\">Name:<input type=\"text\" name=\"user\" value=\"\" /><input type=\"button\" id=\"submitScore\" name=\"submit\" value=\"Submit\" /></div>";
		html += "</div></div>";
		div.innerHTML = html;
		questions.appendChild(div);
		var button = document.getElementById("submitScore");
		button.addEventListener("click",function(e){ that.submitScore.apply(that,[{ "e":e,"tally":that.tally,"total":that.total,"score":score }]); },false);
		
	},
	
	submitScore: function(stats){
		var evt = stats["e"];
		var user = evt.target.previousSibling;
		this.sendStats({ "user":user, "score":stats["score"], "tally":stats["tally"], "total":stats["total"] });
	}
	
}

var Timer = function(){
	
	return {
		init: function(){
			return this.buildTimer();
		},
	
		buildTimer: function(){
			var div = document.createElement("div");
			div.className = "timer";
			div.id = "timer";
			div.style.zIndex = "999";
			return div;
		},

		startTimer: function(){ 
			var that = this;
			var timer = document.getElementById("timer");
			var startDate = new Date();
			var startTime = 5000;
			timer.innerHTML = startTime/1000;
			var interval = setInterval(function(){
				if(startTime <= 0) {
					clearInterval(interval);
					return false;
			    } else {
					startTime -= 10
					timer.innerHTML = Math.round(startTime/1000);
				}
			},10);
		},
		
	}
}

