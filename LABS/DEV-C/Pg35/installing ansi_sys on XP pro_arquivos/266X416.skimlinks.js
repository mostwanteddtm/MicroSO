var skimlinks_pub_id = '266X416';
var skimlinks_site = 'techguy.org';
var skimlinks_domain = 'go.techguy.org';
var skimwords_horizontal_distance = 100;
var skimwords_vertical_distance = 100;
var noskoupon = true;
var noskimproducts = true;
var skimwords_lite = true;
var skimwords_instant = true;
(function(){var U,wa,ka,xa,Ya,Za,$a,ya,ab,bb,cb,za;function db(){C=c.location;J=c.skimwords_decoration||!1;la=c.skimwords_standard||!1;V=c.skimwords_lite||!1;O=c.skimwords_style||!1;P=c.skimwords_weight||!1;G=c.skimwords_color||!1;D=c.skimlinks_tracking||!1;ma=c.skimlinks_site||!1;eb=c.skimlinks_domain||"go.redirectingat.com";fb=(Q=c.skimlinks_google||!1)||"skimout";W=c.skimlinks_target||!1;Aa=c.sl_test||!1;X=c.skimlinks_exclude||[];Ba=c.skimlinks_noright||!1;Ca=c.skimlinks_exrel||!1;H=C.hostname.replace(na,
"");Da=c.skimlinks_byrel||!1;z=c.skimlinks_pub_id||"";r=c.skimlinks_dnt||0;A=c.skimlinks_nocookie||!1;gb=c.skimlinks_maxproducts||3;oa=c.noskimproducts||!1;hb=c.noskim||c.noskimlinks||!1;ib=c.noskim||!1;Y=c.noskimwords||!1;jb=c.noimpressions||!1;K=c.force_location||c.location.href;Ea=c.skimwords_product_icon||!1;kb=c.skimwords_hover_name||"dark";L=c.skimwords_instant||!1;lb=c.skimwords_horizontal_distance||0;mb=c.skimwords_vertical_distance||0;nb=c.skimwords_block_ie7||!1;M=c.skimlinks_blocked_tag||
!1;Fa=c.skimwords_no_limit||!1;Ga=c.skimwords_debug||0;Z=c.skimwords_force_country||!1;$=c.skimwords_force_tree||!1;Ha=c.skimwords_title||!1;Ia=c.skimwords_prio_threshold||0;aa=c.skimwords_merchant_excludes||!1;ba=c.skimwords_merchant_includes||!1;c.skimwords_flyover_version&&(Ja=c.skimwords_flyover_version);c.skimwords_instant_api_location&&(wa=U=c.skimwords_instant_api_location);c.skimlinks_api_location&&(ka=c.skimlinks_api_location);c.skimwords_css_location&&(xa=c.skimwords_css_location);c.skimwords_flyover_template&&
(ob=c.skimwords_flyover_template);c.skimwords_flyover_loop_multi&&(pb=c.skimwords_flyover_loop_multi);c.skimwords_flyover_loop_simple&&(qb=c.skimwords_flyover_loop_simple);c.skimwords_flyover_before&&(rb=c.skimwords_flyover_before);c.skimwords_flyover_after&&(sb=c.skimwords_flyover_after);c.skimwords_flyover_max_title_multi&&(tb=c.skimwords_flyover_max_title_multi);c.skimwords_flyover_max_title_single&&(ub=c.skimwords_flyover_max_title_single);c.skimwords_flyover_big_thumbnails&&(vb=c.skimwords_flyover_big_thumbnails);
if(V||la)L=!0;M&&(M=M.toLowerCase());ca=c.skimlinks_included_classes||[];da=c.skimlinks_included_ids||[];u.pub=z;u.pag=K;u.uc=D}function wb(){var a=xa+kb;d("<link rel='stylesheet' type='text/css' href='"+(a+".css")+"' />").appendTo("head")}function Zb(){return Math.round(Math.random())-0.5}function R(a,b,f){f=f||{};f.charset||(f.charset="utf-8");f.target||(f.target=this);return function(a,b,f){var j=f.charset,g=f.target,f=f.async,c=g.document,h=c.getElementsByTagName("head")[0],d=c.createElement("script"),
t=false;d.type="text/javascript";d.charset=j;d.onload=d.onreadystatechange=function(){var a=this.readyState;if(!t&&(!a||a==="complete"||a==="loaded")){d.onload=d.onreadystatechange=null;t=true;b.call(g)}};d.async=f!==false;d.src=a;h.appendChild(d)}.call(this,a,b||function(){},f)}function $b(a){var b=null;if(d)a(d);else{try{b=c.jQuery}catch(f){}b&&b.fn&&b.fn.jquery&&b.fn.jquery>=Za?(d=I=b,a(d)):R($a,function(){d=I=c.jQuery.noConflict(!0);a(d)},{})}}function xb(a){var b=[],f=0,e;for(e in a)"undefined"!=
a[e]&&(b[f]=e,f++);b.sort(Zb);return b}function ac(a){var b=a.html().slice(0,4);("http"===b||"www."===b)&&a.prepend("<span style='display:none!important;'>&nbsp;</span>")}function ea(a){var b="{",f=0,e="",n;for(n in a)0<f&&(b+=","),"page"!=n&&"object"==typeof a[n]?e=ea(a[n]):"function"!=typeof a[n]&&(e='"'+a[n]+'"'),b+='"'+n+'":'+e,f++;return b+"}"}function Ka(){if(!jb){yb=(new Date).getTime();var a=yb-zb;u.slc=Ab;u.swc=Bb;u.jsl=a;u.guid=S;phrase_data=u.phr;var b=ya+"track.php?data=",f=ea(u).replace(/http:/g,
""),e=encodeURIComponent(f).length,n=0,c=1,j=I.browser.msie?1960:7960;d(phrase_data).each(function(a,d){phrase_string=ea(d).replace(/http:/g,"");current_string=0!=n?",":"";current_string+='"'+n+'":'+phrase_string;if(e+encodeURIComponent(current_string).length<j)f=f.replace('},"pub"',current_string+'},"pub"'),e=encodeURIComponent(f).length;else{var h=b+encodeURIComponent(f)+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":"");(2E3>h.length||!I.browser.msie&&8E3>h.length)&&R(h,!1,{async:!0});u.t=0;f=ea(u).replace(/http:/g,
"");current_string=current_string.replace('"'+n+'":','"0":');f=f.replace('},"pub"',current_string+'},"pub"');e=encodeURIComponent(f).length;n=0;c++}n++});a=b+encodeURIComponent(f)+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":"");(2E3>a.length||!I.browser.msie&&8E3>a.length)&&R(a,!1,{async:!0})}}function bc(a,b){x=d(a).mouseenter(function(){E=!0}).mouseleave(function(){pa();E=!1});x.appendTo(cc);var f=x.find(".flyover2-body");f.html(b);f.find(".skimwords-hover-link").click(La).bind("contextmenu",Ma);f.find(".skimwords-ebay-link").click(Cb).bind("contextmenu",
Cb);x.find(".flyover2-close").click(function(){pa();E=!1});f.find(".flyover2-row").not(".first").hover(function(){d(this).addClass("flyover2-row-hover")},function(){d(this).removeClass("flyover2-row-hover")});f.find(".flyover2-box-container").hover(function(){d(this).addClass("flyover2-box-container-hover")},function(){d(this).removeClass("flyover2-box-container-hover")})}function pa(){if(c.skimwords_persistent_flyover)return!1;c.setTimeout(function(){if(!E&&x){var a=Db;Eb=(new Date).getTime();var b=
{};b.dur=Eb-Fb;b.pub=z;b.pag=K;b.guid=S;b.gid=d(a).attr("data-group-id");b.phr=d(a).text();b.url=d(a).attr("href");b.ver=p;b.pc=x.find(".merc-link").size();a=ya+"hover.php?data="+encodeURIComponent(ea(b))+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":"");R(a,!1,{async:!0});x.fadeOut("fast").slideUp();x.remove();E=x=!1}},ab)}function dc(a,b,f,e,n){a.attr("data-flyover",Na);a.mouseenter(function(c){Oa=setTimeout(function(){var j=fa(ob,{id:f,multiclass:e?"flyovermulti":"",hover_title:n?n:""});x||bc(j,b,e);var j=
c.pageX,g=c.pageY,k=x.width(),h=x.height(),m=d(o).width();d(o).scrollTop();var t=0,j=j-k/2;j+t+k>m&&(t=0-k);x.css({top:g+"px",left:j+"px",marginTop:0-h-5+"px",marginLeft:t+"px"});E||x.fadeIn("fast");Fb=(new Date).getTime();Db=a;E=!0},500)}).mouseleave(function(){Oa&&clearTimeout(Oa);pa();E=!1});Na++}function ec(a){a=a.split(".");a[0]=a[0].split("").reverse().join("");a[0]=a[0].replace(/(\d{3})(?!,)/g,"$1,");a[0]=a[0].split("").reverse().join("");a[0]=0==a[0].indexOf(",")?a[0].substring(1):a[0];return a.join(".")}
function Gb(a){function b(a,b,e,f,c,n,g){return'<a href="'+e.url+'" class="'+(f||"")+' skimwords-link skimwords-hover-link" data-skim-creative="'+g+'" data-skim-product="'+n+'" data-skimwords-word="'+c+'" data-skimwords-id="'+e.product_id+"X"+e.merchant_id+'" title="'+b+'" target="_blank" border=0>'+a+"</a>"}if(a)for(var f=d(".skimwords-link"),e=0,n=f.length;e<n;e++){var c=f[e],j=parseInt(d(c).attr("data-group-id")),c=d(c),g=c.attr("data-skimwords-id"),k=c.attr("data-skimwords-word");c.text();var h=
parseInt(c.attr("data-skim-creative"))%10,m=0,t="",v,F=!0,T,y,B;if(j){if(y=a.groups[j]){Ea&&d("<a href='"+c.attr("href")+"' title='"+c.attr("title")+"' style='border:0px;padding:0;margin:0' class='skimlinks-icon-link' skimlinked='skimlinked' target='_blank'><img src='"+Ea+"'  skimlinked='skimlinked' style='margin: 0px 0px -3px 2px !important; float:none !important;  border:0px;max-width: 16px !important; max-height: 16px !important; float:none !important; display:inline !important;' /></a>").insertAfter(c).bind("contextmenu",
Ma).bind("click",La);v=0;T=!1;var t=[],ga="The availability and pricing displayed are not guaranteed and are subject to change.",F=!0;for(B in y)if(y.hasOwnProperty(B)&&y[B].mt){T=!0;break}for(B in y)if(y.hasOwnProperty(B)){var s=y[B];if(T){if(F=!1,!s.mt)continue}else-1!==s.url.indexOf("ebay.")&&(F=!1);1E7<s.product_id&&6!=parseInt(h)?B=s.product_id-1E7:(parseInt(h),B=s.product_id);var r=B==g,o=T?tb:ub;if(v<gb&&s.price&&" "!=s.price){var q="",u="$",m=1;v++;c.attr("title","");s.price=ec(s.price.toString());
full_title=s.title;s.title.length>o&&(s.title=s.title.substr(0,o-3)+"...");if(s.country)if("GB"===s.country)u="&pound;";else if("DE"==s.country)var ga=String.fromCharCode(252),u=String.fromCharCode(246),o=String.fromCharCode(228),w=String.fromCharCode(196),ga="Die Verf"+ga+"gbarkeit der Produkte und der ver"+u+"ffentlichte Preis werden nicht garantiert. Preis"+o+"nderungen und "+w+"nderung der Verf"+ga+"gbarkeit vorbehalt.",u="&euro;";o={};o.imageLink=b('<img src="'+s.image+(vb?"":"_thumb")+'" style="border:0px !important;" title="'+
full_title+'" />',"",s,"image",k,B,"2"+p+"1"+h);o.titleLink=b(s.title,full_title,s,"product-link flyover2-link",k,B,"2"+p+"2"+h);o.merchantLink=b(s.merchant_name,"",s,"merc-link flyover2-clickable",k,s.product_id,"2"+p+"3"+h);o.priceLink=b(u+s.price,"",s,"flyover2-clickable",k,s.product_id,"2"+p+"3"+h);o.emptyLink=b("",full_title,s,"flyover2-arrow product-link",k,s.product_id,"2"+p+"2"+h);o.plainLink=s.url;T?(p=parseInt(Ja)+1,10>p&&(p="0"+p),o.closeButton=r?"<div class='flyover2-close nowidth'></div>":
"",q=fa(pb,o)):(p=parseInt(Ja),10>p&&(p="0"+p),r&&(q=fa(rb,o)),o.extraClass=r?"flyover2-row-main":"",q+=fa(qb,o));r?t.splice(0,0,q):t.push(q)}}F&&(g="_sacat=See-All-Categories&_nkw="+k,skim_gets="&skimlinks_search_product=ebay&skimlinksurl="+encodeURIComponent("http://www.ebay.com/sch/i.html?")+"&skimlinkspubid="+z,naked_link="http://www.ebay.com/sch/i.html?"+g,ebay_link="http://go.redirectingat.com/forms.php?"+g+skim_gets,t.push(fa(sb,{link1:'<a href="'+naked_link+'" data-skimlinks-href="'+ebay_link+
'" target="_blank" class="search-link flyover2-clickable skimwords-ebay-link" title="Search on eBay">Search on eBay</a>',link2:'<a href="'+naked_link+'" data-skimlinks-href="'+ebay_link+'" target="_blank" class="flyover2-arrow flyover2-clickable skimwords-ebay-link" title="Search on eBay"></a>'})));t=t.join("")}m&&(!(d.browser.msie&&"7.0">d.browser.version)&&d.support.boxModel)&&dc(c,t,j,T,ga)}}}function fc(){var a=la?"standard":V?"lite":"";if(d.browser.msie)if(c.XDomainRequest){var b=new XDomainRequest;
b&&(b.open("POST",U),b.onload=function(){var a={};try{a=JSON.parse(b.responseText)}catch(f){a=eval("("+b.responseText+")")}qa(a)},b.onerror=function(){},b.onprogress=function(){},b.ontimeout=function(){},b.async=!0,b.send("data="+encodeURIComponent('{"instant":"1","pubcode":"'+z+'","page":"'+K+'"'+(Z?',"force_country":"'+Z+'"':"")+($?',"force_tree":"'+$+'"':"")+(aa?',"merchant_excludes":"'+aa+'"':"")+(ba?',"merchant_includes":"'+ba+'"':"")+"}")+"&filter="+a+"&content="+encodeURIComponent(N)+(0!=r?
"&dnt="+r:"")+(A?"&fdnt=1":"")))}else L=!1,ha("skimwordsDataCallback");else try{d.ajax({url:U,type:"POST",async:!0,crossDomain:!0,data:{data:'{"instant":"1","pubcode":"'+z+'","page":"'+K+'"'+(Z?',"force_country":"'+Z+'"':"")+($?',"force_tree":"'+$+'"':"")+(aa?',"merchant_excludes":"'+aa+'"':"")+(ba?',"merchant_includes":"'+ba+'"':"")+"}",debug:Ga,filter:a,content:N,dnt:r,fdnt:A?"1":""},success:function(a){var b={};try{b=JSON.parse(a)}catch(f){b=eval("("+a+")")}qa(b)},error:function(){L=!1;ha("skimwordsDataCallback")},
complete:function(){}})}catch(f){L=!1,ha("skimwordsDataCallback")}}function gc(a,b){var f=b.join(",").replace("class=","class^=");return a.is(f)?!1:!0}function ra(a,b){function f(a){var b=a.nodeName===e?d.trim(a.nodeValue):null;return b?(w.push(a),l++,10>l?j.push(b):(l=0,j.push(b+"\n"),N+=j.join(" SKMLNKS "),j=[]),!0):!1}a=a||[];b=b||[];0==a.length&&(a[0]="body");b.push("div[class=widget-content]");b.push("div[class=googleAdText]");b.push("div[id=ad]");b.push("div[id=banner]");b.push("div[id=advertisement]");
b.push("div[id=adv_container]");b.push("div[class=ad]");b.push("div[class=banner]");b.push("div[class=advertisement]");b.push("div[class=ad_container]");b.push("div[id=ads]");b.push("div[class*=ArticleAd]");b.push("div[id*=googleAdUnitIframe]");b.push("div[id*=adBlock]");b.push("div[class*=adBlock]");b.push("div[id=BA]");-1!=C.href.indexOf(".google.")?(b.push("td[class=gac_c]"),b.push("table[id=mbEnd]"),b.push("span[id=taw]"),b.push("td[class=std]"),b.push("table[class=gssb_e]")):-1!=C.href.indexOf(".yahoo.")?
(b.push("ul[class=spns reducepx-spnslist]"),b.push("ul[class*=reducepx-spnslist]"),b.push("ul[id=east]")):-1!=C.href.indexOf(".aol.")?(b.push("div[class=sllLink]"),b.push("div[class=n]")):-1!=C.href.indexOf(".bing.")&&(b.push("div[class=sb_adsW]"),b.push("div[id=sidebar]"));if(!w.length)for(var e=o.createTextNode("").nodeName,c=[],l=0,j=[],g=0,k=a.length;g<k;g++)for(var h=d(a[g]),m=0,t=h.length;m<t;m++){c.push(h[m]);for(j=[];0<c.length;)if(node=c.shift())if(node.hasChildNodes()){children_to_callback=
[];i=0;for(k=node.childNodes.length;i<k;i++)(child=node.childNodes[i])&&child.nodeName&&!f(child)&&-1!==",p,section,body,div,span,ul,ol,li,table,tbody,td,tr,th,tfoot,col,colgroup,em,strong,big,small,blockquote,cite,b,dl,dfn,dd,dt,ins,form,legend,noframes,pre,noscript,center,font,i,article,".indexOf(","+child.nodeName.toLowerCase()+",")&&(Pa(I(child),"skimwords",!0)&&gc(I(child),b))&&c.push(child)}else f(node);N+=j.join(" SKMLNKS ")+"\n";j=[]}}function Hb(a){return a.replace(/[-[\]{}()*+?.,\\^$|#]/g,
"\\$&")}function Ib(a,b,f,e,c,d,j,g,k,h){var m=a.word.split(" "),o=Hb(a.word);a.title="de"==Qa.toLowerCase()?"Shopping link hinzugef\u00c3\u00bcgt von SkimWords":Ha?Ha:"Shopping link added by SkimWords";if("cn"===b||"ko"===b||"ja"===b)b="(?:"+o+")",f='<a href="'+a.link+'" class="skimwords-link" target="_blank" style="'+f+" "+e+" "+c+" "+d+' " data-skimwords-id="'+j+'" data-skimwords-word="'+encodeURIComponent(a.word)+'" data-group-id="'+g+'" data-skim-creative="'+h+'" data-skim-product="'+k+'" title="'+
a.title+'">$1</a>';else if((1<m.length||"4"!==a.action_type||1===m.length&&/(?:\d[a-z])|(?:[a-z]|\d)/i.test(m[0]))&&(2>m.length||/[a-zA-Z]+/.test(a.word)))b="(?:^|[\\s]+)(?:\\\\;\\.|,\\'\\\"\\(\\)\\/\\?])?("+o+")(?:\\'s)?(?:[\\\\;,\\.\\'\\\"|\\(\\)\\/\\?])*(?:[\\s]+|$)",f='$1$2<a href="'+a.link+'" class="skimwords-link" target="_blank" style="'+f+" "+e+" "+c+" "+d+' " data-skimwords-id="'+j+'" data-skimwords-word="'+encodeURIComponent(a.word)+'" data-group-id="'+g+'" data-skim-creative="'+h+'" data-skim-product="'+
k+'" title="'+a.title+'">$3$4</a>$5$6';else return null;a=b.replace(/\?:/g,"");return{search_regex:RegExp(b,"i"),repl_regex:RegExp(a,"i"),repl_text:f}}function Jb(a,b,f,e){var c,l,j,g,k,h;if(!a)return!1;f=o.createTextNode("").nodeName;c=a.data;for(var m=0,t=Ra.length;m<t;m++)if(g=Ra[m],b[g].group_id?(l=b[g].group_id,j="2"+p+"0"+b[g].action_type):(l=0,j="1"+p+"0"+b[g].action_type),h=b[g].id,k=1E7<parseInt(h)&&6!=b[g].action_type?h-=1E7:0,j=Ib(b[g],Sa,G,P,J,O,h,l,k,j),l=a&&0<b[g].limit&&j&&j.search_regex.test(c)){repl_regex=
j.repl_regex;c=j.repl_text;if(!(0==b[g].limit||!Fa&&ia==q.maxkeywords)){ia++;b[g].limit--;Kb++;m={};m.w=b[g].word;m.lp=b[g].link;0==b[g].group_id?(m.t="1"+p+"0"+b[g].action_type,m.pid=0):(m.t="2"+p+"0"+b[g].action_type,m.pid=6==b[g].action_type?g:g-1E7);-1==d.inArray(m,u.phr)&&u.phr.push(m);b=a.data.replace(repl_regex,c);g=o.createElement("span");c=o.createDocumentFragment();for(g.innerHTML=b;g.firstChild;)g.firstChild.nodeName==f?(obj=c.appendChild(g.firstChild),w.push(obj)):obj=c.appendChild(g.firstChild);
-1!=e&&(w[e]=0);d(a).replaceWith(c)}return!1}}function Lb(a,b){var f,e;if(Fa||ia<q.maxkeywords){f=xb(b);for(var c=0,l=f.length;c<l;c++){var j=f[c];if(0===a||j==a||0>a&&j!=-a){Ra=xb(b[j]);var g=w.length,k=Math.ceil(g/2);for(e=0;e<=k;e++){var h=d(w[e]).parent().eq(0);Jb(w[e],b[j],h,e);e!=k&&(h=d(w[g-1-e]).parent().eq(0),Jb(w[g-1-e],b[j],h,g-1-e));g=w.length;k=Math.ceil(g/2)}}}}}function Ta(a,b){var f=parseInt(a.phrase.action_type),e=parseInt(b.phrase.action_type),c=parseFloat(a.phrase.gpr),d=parseFloat(b.phrase.gpr),
j=e-f,g=d-c;if(!g){if(!isNaN(c)&&!isNaN(d))return!j?b.phrase.word.length-a.phrase.word.length:4===e?1:4===f?-1:j;if(isNaN(c))return 1;if(isNaN(d))return-1}return 0<g?1:-1}function hc(a){for(var b,f=[],e=0,c=w.length;e<c;e++){b=w[e];var d=b.nodeValue,j=b.parentNode;if(j){var g=ic(b,a);g.sort(function(a,b){return a.start-b.start});if(g&&g.length){for(var k=o.createDocumentFragment(),h=0,m=0,t=g.length;m<t;m++){var v=g[m],F=o.createElement("span");F.className="skimwords-potential";h=o.createTextNode(d.substring(h,
v.start));k.appendChild(h);F.innerHTML=v.text;k.appendChild(F);h={};h.node=F;h.match=v;f.push(h);h=v.start+v.text.length}d=o.createTextNode(d.substring(h));k.appendChild(d);j.replaceChild(k,b)}}}return f}function ic(a,b){var f,c,d,l,j,g,k,h;overlapping_matches=[];matches=[];if(!a)return matches;o.createTextNode("");f=a.data;(function(){if(sa)h=sa;else{h=[];for(var a in b)if(b.hasOwnProperty(a)){var f=b[a],g;for(g in f)if(f.hasOwnProperty(g)){var k=f[g];k.group_id?(c=k.group_id,d="2"+p+"0"+k.action_type):
(c=0,d="1"+p+"0"+k.action_type);j=k.id;l=1E7<parseInt(j)&&6!=k.action_type?j-=1E7:0;var m=Ib(k,Sa,G,P,J,O,j,c,l,d);m&&h.push({phrase:k,repl_regex:m.repl_regex,replacement:m.repl_text,regex:m.search_regex})}}h.sort(Ta);sa=h}})();for(var m=0,t=h.length;m<t;m++){var v=h[m];phrase=v.phrase;k={start:-1};k.phrase=phrase;k.text=null;(function(){if(a&&0<phrase.limit){var b=f.match(v.regex);if(b){var c=b[0].indexOf(b[1]);k.start=b.index+(-1!==c?c:0);k.text=f.substring(k.start,k.start+b[1].length)}else k.start=
-1}})();g=0;-1!=k.start&&k.text&&(g=1);g?(k.repl_regex=v.repl_regex,k.replacement=v.replacement,overlapping_matches.push(k)):k.start=-1}(function(){if(overlapping_matches&&overlapping_matches.length){overlapping_matches.sort(Ta);for(var a=overlapping_matches.length,b=[],f=0;f<a;f++){var c=overlapping_matches[f],e={},d=!0;e.lower=c.start;e.upper=c.start+c.text.length;for(var g=0,j=b.length;g<j;g++){var h=b[g];if(e.lower>=h.lower&&e.lower<=h.upper||e.upper<=h.upper&&e.upper>=h.lower){d=!1;break}}d&&
(matches.push(c),b.push(e))}overlapping_matches=null}})();return matches}function jc(a,b){if(a.length){var f,c,n,l,j=[],g=0,b=b||0,k=d.browser.msie&&"9.0">d.browser.version;k&&(n=d("body").text().length,3E4<n?b=Math.ceil(n/1E4):k=!1);n=0;for(l=a.length;n<l;n++){c=a[n];f=c.node;c=c.match;var h=c.phrase.gpr?parseFloat(c.phrase.gpr):0,m=!1;if("1"===c.phrase.action_type||"2"===c.phrase.action_type||Ia&&h>Ia)m=!0;k&&(m=!0);"17075X740592"===z&&d(f).parents(".atma-norules").length&&(m=!0);if(Pa(d(f),"skimwords")&&
(m||kc(f,j))){g++;h=void 0;h=c.phrase;if(0!=h.limit){ia++;h.limit--;Kb++;m={};m.w=h.word;m.lp=h.link;0==h.group_id?(m.t="1"+p+"0"+h.action_type,m.pid=0):(m.t="2"+p+"0"+h.action_type,m.pid=6==h.action_type?h.id:h.id-1E7);-1==d.inArray(m,u.phr)&&u.phr.push(m);h=f.data?f.data:f.childNodes[0].data;c=h.replace(c.repl_regex,c.replacement);h=o.createElement("span");m=o.createDocumentFragment();for(h.innerHTML=c;h.firstChild;)void 0==h.firstChild.nodeName?(obj=m.appendChild(h.firstChild),w.push(obj)):obj=
m.appendChild(h.firstChild);d(f).replaceWith(m)}if(b&&g>=b)break}}}}function Ua(a){var b=0,c=0;if(a.offsetParent){do b+=a.offsetLeft,c+=a.offsetTop;while(a=a.offsetParent)}return{x:b,y:c}}function lc(a,b,c){var e=0,d=a.length-1,l,j;for("function"!==typeof c&&(c=cmp);e<=d;)if(l=Math.floor((d+e)/2),j=c(b,a[l]),0<j)e=l+1;else if(0>j)d=l-1;else return{found:!0,index:l};return{found:!1,index:e}}function kc(a,b){function c(a,b){Math.abs(a.x-b.x)<=p&&Math.abs(a.y-b.y)<=y&&(q=!0);return a.y===b.y?a.x-b.x:
a.y-b.y}var e,d,l,j,g,k,h,m,t,v,r;l=Ua(a);var p=lb,y=mb,q=!1;if(!p&&!y)return!0;p=!p?0:p;y=!y?4:y;d=[{test:function(a){return 0<a&&a<b.length},count:function(a){return a-1}},{test:function(a){return a<b.length},count:function(a){return a+1}}];e=o.createElement("span");e.style.position="absolute";a.nextSibling?a.parentNode.insertBefore(e,a.nextSibling):a.parentNode.appendChild(e);e=Ua(e);e=o.createElement("span");e.style.position="absolute";a.nextSibling?a.parentNode.insertBefore(e,a.nextSibling):
a.parentNode.appendChild(e);e=Ua(e);j=[l,e];for(g=0;g<j.length;g++){k=j[g];if(q)break;h=lc(b,k,c);for(v=0;v<d.length&&!(r=d[v],q);v++)for(m=r.count(h.index);r.test(m);m=r.count(m)){t=b[m];if(!(Math.abs(k.y-t.y)<=y))break;if(Math.abs(k.x-t.x)<=p){q=!0;break}}}if(q)return!q;d=l.y===e.y?l.x-e.x:l.y-e.y;0<d?d=e:0>d?(d=l,l=e):(d=l,l=null);h.index===b.length?(b.push(d),l&&b.push(l)):l?b.splice(h.index,0,d,l):b.splice(h.index,0,d);return!q}function qa(a){if(q=a)if(q.guid&&(S=q.guid),q.lang&&(Sa=q.lang.toLowerCase()),
ra(q.includes,q.excludes),w.length&&d(q.words).size()){a=1;if(d.browser.mozilla){var b=/Firefox\/(\d.\d)/.exec(navigator.userAgent);b&&(2<=b.length&&3.7>=parseFloat(b[1]))&&(a=0)}else d.browser.msie&&"8.0">d.browser.version&&(a=0);if(a){for(var f=hc(q.words),a=0,b=f.length;a<b;a++)f[a].orig_i=a;f.sort(function(a,b){var c=Ta(a.match,b.match);return c?c:a.orig_i-b.orig_i});jc(f,q.maxkeywords)}else Lb(4,q.words),Lb(-4,q.words);if(d.browser.msie&&"9.0">d.browser.version)for(var f=d(".skimwords-link"),
e,n,l=/^\s/,a=0,b=f.length;a<b;a++){n=f[a];if((e=n.previousSibling)&&(e.nodeValue&&e.nodeValue.length)&&l.test(e.nodeValue[e.nodeValue.length-1]))e.nodeValue+=" ";if((e=n.nextSibling)&&e.nodeValue&&e.nodeValue.length&&l.test(e.nodeValue[0]))e.nodeValue=" "+e.nodeValue}Bb=d(".skimwords-link").length;c.setTimeout(function(){for(var a=d(".skimwords-link"),b,c=0,f=a.length;c<f;c++){b=d(a[c]);b.click(La);b.bind("contextmenu",Ma)}if(z==="17075X740592"){a=d(".atma-norules a.skimwords-link");c=0;for(f=a.length;c<
f;c++){a[c].style.color="#C9C7C7 !important";a[c].style.fontStyle="normal !important"}}},10)}oa||(q.groups?(ja||(wb(),ja=!0),Gb({groups:q.groups})):(Mb=d(o),Mb.ready(function(){var a=d("a[href]:not(:has(img))"),b={},c={},f={};d([]);d([]);for(var e=0,n=a.length;e<n;e++){var l=a[e],o=l.className,q=l.href,p=l.hostname.replace(na,""),l=l.getAttribute("data-skimwords-id");if(-1==q.indexOf(H)||!H)if(o&&-1!=o.indexOf("skimwords")){if(p&&!c[p]&&(Nb.push(p),c[p]=!0),l){o=l.split(" ");q=0;for(p=o.length;q<
p;q++)if(l=o[q],(l=d.trim(l))&&!f[l])Ob.push(l),f[l]=!0}}else p&&!b[p]&&(Pb.push(p),b[p]=!0)}d(".skimwords-link");d('a[href^=http://]:not([href*="'+H+'"],[class=skimwords-link])');ja||(wb(),ja=!0);a='{"groups": [';b=0;c=d(".skimwords-link");f=0;for(e=c.length;f<e;f++)n=c[f],o=d(n).attr("data-group-id"),parseInt(o)&&"0"!=parseInt(o)&&(0!=b&&(a+=","),a+='"'+d(n).attr("data-group-id")+'"',b++);b&&R(bb+"?callback=productDataCallback&data="+(a+"]}")+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":""))})));Ka()}function ha(a){if(V||
la)var a="instantDataCallback",b=V?"&filter=lite":"&filter=standard";else b="";if(L)var c=encodeURIComponent('{"instant":"1","page":"'+K+'"}'),e=U;else c=encodeURIComponent('{"page":"'+K+'"}'),e=wa;R(e+"?callback="+a+"&data="+c+"&debug="+Ga+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":"")+b)}function mc(){var a;if("undefined"===typeof ta){ta={};a=X.concat(cb);for(var b=0,c=a.length;b<c;b++){var e=a[b];ta[e]=e.length}}return ta}function Qb(a){var b=!1,c=mc(),e=a.length;d.each(c,function(c,f){if(0===c.indexOf("*")){if(c=
c.slice(1),f-=1,-1!==a.lastIndexOf(c)&&a.lastIndexOf(c)===e-f)return b=!0,!1}else if(a===c)return b=!0,!1});return b}function Va(a){var b;if(!(b=!a))if(!(b=Da&&a===Da)){if("undefined"===typeof ua){ua={};b=Ca?[Ca]:[];b=b.concat(za);for(var c=0,e=b.length;c<e;c++)ua[b[c]]=!0}b=!ua[a]}return b}function nc(a){var b=c.pageTracker,f=c.urchinTracker,a="/"+fb+"/"+a;b&&b._trackPageview?b._trackPageview(a):f&&f(a)}function va(a,b){var c,e,d;a&&("img"==a.prop("tagName").toLowerCase()&&(a=a.parent()),e=a[0],
c=e.href,d=a.data("skimlinks-href"),d||(d=a.hasClass("skimwords-link")?"http://"+Ya+"/?id="+z+(D?"&xcust="+D:"")+"&xs=2&url="+encodeURIComponent(c)+"&xguid="+S+(void 0!==a.attr("data-skimwords-word")?"&xword="+a.attr("data-skimwords-word"):"&xword=")+(void 0!==a.attr("data-skim-creative")?"&xcreo="+a.attr("data-skim-creative"):"&xcreo=0")+(void 0!==a.attr("data-skim-product")?"&xpid="+a.attr("data-skim-product"):"&xpid=0")+"&sref="+encodeURIComponent(C)+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":""):Pa(a,"skimlinks")?
"http://"+eb+"/?id="+z+(ma?"&site="+ma:"")+(Aa?"&test="+Aa:"")+(D?"&xcust="+D:"")+"&xs=1&url="+encodeURIComponent(c)+"&xguid="+S+(a&&void 0!==a.attr("data-skim-creative")?"&xcreo="+a.attr("data-skim-creative"):"&xcreo=0")+"&sref="+encodeURIComponent(C)+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":""):c,a.data("skimlinks-href",d)),b&&nc(c),a.data("skimlinks-orig-link")||a.data("skimlinks-orig-link",c),e.href=d,setTimeout(function(){e.href=a.data("skimlinks-orig-link")},100))}function Wa(a,b){var c=a.target;anchor=
d(c);c.href||(c=a.currentTarget,anchor=d(c));va(anchor,b)}function Ma(a){Wa(a,!1)}function La(a){Wa(a,Q)}function Rb(a){Wa(a,Q)}function Cb(a){var b=a.target;anchor=d(b);b.href||(b=a.currentTarget,anchor=d(b));anchor.data("skimlinks-href",anchor.attr("data-skimlinks-href"));va(anchor,Q)}function Sb(a){a=a.target;d(a);a=encodeURIComponent('{"pubcode":"'+z+'","referrer":"'+C+'","site":"'+ma+'","url":"'+a.href+'","custom":"'+D+'","product":"1"}');d.getScript(ka+"?call=track&data="+a+(0!=r?"&dnt="+r:
"")+(A?"&fdnt=1":""))}function oc(a,b){var c=!1;b.merchant_domains&&d.each(b.merchant_domains,function(b,d){if(a==d)return c=!0});return c}function pc(a){if(ca.length)for(var b=0,c=ca.length;b<c;b++)if(a.parents("."+ca[b]).length)return!0;if(da.length){b=0;for(c=da.length;b<c;b++)if(a.parents("#"+da[b]).length)return!0}return!1}function qc(a){if(!M)return!0;a=a[0].previousSibling;if(!a)return!0;var a=d.trim(I(a).text().toLowerCase()),b=a.indexOf("["+M+"]");return!(-1!==b&&b+(M.length+2)===a.length)}
function Tb(){if(Y||ib)return Ub;G&&(G=-1==G.indexOf("#")?"color:#"+G+" !important;":"color:"+G+" !important;");P=P?"font-weight: "+P+" !important;":"";O=O?"font-style: "+O+" !important;":"";J="double"==J?"border-bottom: 1px double !important;":J?"text-decoration: "+J+" !important;":"text-decoration: underline !important;";L?ha("instantDataCallback"):ha("skimwordsDataCallback")}function Xa(){if(hb)return Y?Ka():Tb(),Ub;X=X.concat(za);c.skimlinks_site&&X.push(c.skimlinks_site);D&&!rc.test(D)&&(D=!1);
for(var a=d("a[href]"),b=[],f={},e=0,n=a.length;e<n;e++){var l=a[e],j=d(l),g=l.hostname.replace(na,""),l=d.trim(l.href),j=j.attr("rel");Vb.test(l)&&(-1===g.indexOf(H)&&-1===H.indexOf("."+g))&&!Qb(g)&&Va(j)&&(g&&!f[g])&&(b.push(g),f[g]=!0)}a=encodeURIComponent;f='{"pubcode":"'+z+'","domains":';e="";if(b.length){n=0;for(g=b.length;n<g;n++)e+='"'+b[n]+'",';e=e.slice(0,-1)}b=a(f+("["+e+"]")+"}");d.getScript(ka+"?callback=skimlinksApplyHandlers&data="+b+(0!=r?"&dnt="+r:"")+(A?"&fdnt=1":""));return!0}function Wb(){Nb=
[];Ob=[];Pb=[];merchantLimits=[];totalDisplayed=d(".skimlinks-icon-link").size();w=[];N="";Na=0;var a=d("a");a.data("skimlinks-href","");a.data("skimlinks-orig-link","");db();Xa()}function Xb(){for(var a=d(".skimwords-link"),b=ia=0,c=a.length;b<c;b++){var e=d(a[b]);e.after(e.text());e.remove()}}function Yb(){zb=(new Date).getTime();-1==C.href.indexOf("https://")&&$b(function(a){a.browser.msie&&"8.0">a.browser.version&&(nb?Y=!0:(a=/Windows NT (\d.\d)/.exec(navigator.userAgent))&&(2<=a.length&&6>=parseFloat(a[1]))&&
(oa=!0));oa&&(p="00");Xb();Xa()})}var fa=function(){var a=RegExp("{{([a-z0-9_][\\.a-z0-9_]*)}}","gi");return function(b,c){return b.replace(a,function(a,b){for(var d=b.split("."),j=d.length,g=c,k=0;k<j;k++)if(g=g[d[k]],k===j-1)return g})}}(),c=this,o=c.document;$a="https://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js";Za="1.5.5";Ya=c.skimlinks_domain||"go.redirectingat.com";cb="*doubleclick.net *mjxads.internet.com *pgpartner.co.uk *pgpartner.com *pricegrabber.co.uk *pricegrabber.com *overture.com *youtube.com".split(" ");
za=["noskim","norewrite"];wa=U="http://i.skimresources.com/api/index.php";bb="http://i.skimresources.com/api/product.php";ka="http://r.skimresources.com/api/";ya="http://t.skimresources.com/api/";xa="http://s.skimresources.com/css/flyover-";ab=250;var jb,Y,ib,hb,oa,gb,z,Qa="",S="",r=0,A=0,Ub=function(){},na=/^www\./,Vb=/^\/\/|https?:\/\//,rc=/^[a-z0-9_\\|]+$/i,C,ta,ua,ca=[],da=[],zb=null,yb=null,Fb=null,Eb=null,H,Da,Ca,Ba,X,Aa,W,Q,fb,eb,ma,D,Ab=0,G,P,O,V,la,J,L,Bb=0,p="02",Ja="02",w=[],N="",kb,Sa=
"en",lb,mb,nb,M,Fa,Ga,Ha,Ia,Z,$,q,K,Kb=0,ia=0,Ra,ja=!1,sa,Ea,ba=!1,aa=!1,ob="<div id='flyover2-{{id}}' class='flyover2-outer {{multiclass}}'><div class='flyover2-body'></div><div class='flyover2-bottom'><a class='bottom-link' target='_blank' href='http://www.skimlinks.com/?ref=flyover' ref='hoverover'></a><a class='bottom-link-2' title='{{hover_title}}'></a></div></div>",pb='<div class="flyover2-row">{{closeButton}}{{imageLink}}{{titleLink}}<div class="flyover2-box-container"><div class="flyover2-merc-section"><span class="flyover2-merc">{{merchantLink}}</span></div><div class="flyover2-price">{{priceLink}}</div>{{emptyLink}}<br /></div></div>',
qb='<div class="flyover2-row {{extraClass}}"><div class="flyover2-merc-section"><span class="flyover2-merc">{{merchantLink}}</span></div><div class="flyover2-price">{{priceLink}}</div>{{titleLink}}<br /></div>',rb='<div class="flyover2-row first"><div class="flyover2-close nowidth"></div>{{imageLink}}{{titleLink}}</div>',sb='<div class="flyover2-row"><div class="flyover2-search-section">{{link1}}</div>{{link2}}</div>',tb=73,ub=63,vb=!1,x,Na=0,Db,E=!1,Oa=null,Mb,cc=o.body,Nb=[],Ob=[],Pb=[],u={pag:"",
phr:[],pub:"",slc:0,swc:0,jsl:0,jsf:"",guid:"",uc:"",t:1},d,I;db();var Pa=function(){var a=/\bnoskim\b/i;return function(b,c,d){var n=b[0].className||"",d=d||!1;return!a.test(n)&&!RegExp("\\b"+Hb("no"+c)+"\\b","i").test(n)&&(d||0==b.parents(".no"+c).length&&0==b.parents(".noskim").length)?!0:!1}}();c.skimlinks=Xa;c.mugicPopWin=Rb;c.mugicRight=Rb;c.skimwordsDataCallback=qa;c.instantDataCallback=function(a){a.country&&(Qa=a.country);if(1==a.nc){if(a.includes)try{ra(a.includes,a.excludes)}catch(b){ra(["body"],
[])}else ra(["body"],[]);fc()}else 2!=a.nc&&qa(a)};c.skimlinksApplyHandlers=function(a){var b=d("a[href]"),c=0<ca.length||0<da.length;a.country&&(Qa=a.country);a.guid&&(S=a.guid);for(var e=0,n=b.length;e<n;e++){var l=b[e],j=d(l),g=l.hostname.replace(na,""),l=d.trim(l.href),k=j.attr("rel"),h=d.browser.msie;if((!c||pc(j))&&qc(j))if(oc(g,a)){if(Va(k)){W&&j.attr("target",W);if(h){if(-1!==encodeURIComponent(l).indexOf("%C3%82%C2%A3"))return!0;ac(j)}j.click(function(){var a=d(this);va(a,Q)});Ab++;Ba||j.bind("contextmenu",
function(){var a=d(this);va(a,Q)})}}else Vb.test(l)&&(-1===g.indexOf(H)&&-1===H.indexOf("."+g))&&!Qb(g)&&Va(k)&&(W&&j.attr("target",W),j.click(Sb),Ba||j.bind("contextmenu",Sb))}Y?Ka():Tb()};c.productDataCallback=Gb;c.skimlinksReload=Wb;c.skimwordsReload=function(){pa();E=!1;sa=null;d("head").find("link[rel=stylesheet]").each(function(){this.href&&-1!==this.href.indexOf("skimlinks.")&&d(this).remove()});ja=!1;Xb();Wb()};c.jQuery?c.jQuery(o).ready(function(){Yb()}):Yb()})();