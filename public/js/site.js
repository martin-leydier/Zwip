jQuery.fn.textNodes = function() {
  return this.contents().filter(function() {
    return (this.nodeType === Node.TEXT_NODE && this.nodeValue.trim() !== "");
  });
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCart() {
  var cart = getCookie("cart");
  var cartArray = [];
  if (cart !== "") {
    try {
      cartArray = JSON.parse(decodeURIComponent(cart));
    }
    catch(err) {
      console.warn('Could not parse cookie, will reset its value');
      console.warn(err);
      setCart([]);
    }
  }
  return cartArray;
}

function setCart(cartArray) {
  setCookie("cart", encodeURIComponent(JSON.stringify(cartArray)), 30);
  $('#cart').textNodes().replaceWith(cartArray.length);
}

function addCart(path) {
  cartArray = getCart();
  if (!cartArray.includes(path)) {
    cartArray.push(path);
    setCart(cartArray);
  }
  console.debug("cart: " + JSON.parse(decodeURIComponent(getCookie("cart"))));
  event.stopImmediatePropagation();
}

function removeFromCart(path, removeNode) {
  cartArray = getCart();
  cartArray = cartArray.filter(function(el) {
    return el !== path;
  });
  setCart(cartArray);
  if (removeNode) {
      removeNode.remove();
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


async function multiDownload() {
  cartArray = getCart();
  for (var i = cartArray.length - 1; i >= 0; i--) {
    var link = document.createElement("a");
    link.download = cartArray[i];
    link.href = "/.zip?files=" + encodeURI(cartArray[i]);
    link.click();
    removeFromCart(cartArray[i]);
    await sleep(500);
  }
}


function generateBreadCrumb() {
  var $breadcrumb = $("<a>", {"class": "section", "href": "/", "onclick": "event.preventDefault();navigateContent('/')"})
                    .append($("<i>", {"class": "i inverted home icon path-separator"}));
  $('#breadcrumb').html('')
  $('#breadcrumb').append($breadcrumb);
  var curPathArray = window.location.pathname.split('/');
  var arrayLength = curPathArray.length;
  var path = "/";
  // Skip first and last as they are empty
  for (var i = 1; i < arrayLength - 1; i++) {
    if (curPathArray[i] == "")
      continue;
    path += curPathArray[i] + "/";
    $('#breadcrumb').append($("<a>", {"class": "section", "href": path, "onclick": "event.preventDefault();navigateContent('" + path + "')"})
      .append($("<i>", {"class": "i  right angle small icon inverted path-separator"}))
      .append(decodeURI(curPathArray[i])));
  }
}

function navigateContent(path, pushState = true) {
  if (path[0] !== '/')
    path = window.location.pathname + path
  NProgress.start();
  console.debug('Loading content at: ' + path);
  $.ajax({
    url: path,
    type: 'GET',
    dataType: 'html'
  })
  .done(function(data) {
    if (pushState)
      history.pushState(null, null, path);
    $('#content').html(data);
  })
  .fail(function(data) {
    console.error("Failed to load new page");
    console.error(data);
  })
  .always(function() {
    generateBreadCrumb();
    NProgress.done();
  });
}

window.addEventListener("popstate", function(e) {
  navigateContent(location.pathname, false);
});
