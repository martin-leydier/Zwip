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
  console.debug("cart: " + JSON.parse(decodeURIComponent(getCookie("cart"))))
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
    var pathArray = cartArray[i].split('/').filter(function(el) {
      return el !== "";
    });
    link.download = ""; //pathArray[pathArray.length - 1];
    link.href = cartArray[i];
    link.click();
    removeFromCart(cartArray[i]);
    await sleep(500);
  }
}

function navigateContent(path) {
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
    history.pushState(null, null, path);
    $('#content').html(data);
  })
  .fail(function(data) {
    console.error("Failed to load new page");
    console.error(data);
  })
  .always(function() {
    NProgress.done();
  });
}
