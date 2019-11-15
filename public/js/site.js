function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i <ca.length; i++) {
    let c = ca[i];
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
  let d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  let expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCart() {
  let cart = getCookie("cart");
  let cartArray = [];
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
  document.getElementById('cartCount').textContent = cartArray.length
}

function addCart(path) {
  path = decodeURIComponent(path);
  let cartArray = getCart();
  if (!cartArray.includes(path)) {
    cartArray.push(path);
    setCart(cartArray);
  }
  console.debug("cart: " + JSON.parse(decodeURIComponent(getCookie("cart"))));
  event.stopImmediatePropagation();
}

function removeFromCart(path, removeNode) {
  path = decodeURIComponent(path);
  let cartArray = getCart();
  cartArray = cartArray.filter(function(el) {
    return el !== path;
  });
  setCart(cartArray);
  if (removeNode) {
      removeNode.remove();
  }
  if (cartArray.length === 0) {
    let empty = document.getElementById('emptyCart');
    if (empty) {
      empty.removeAttribute("hidden");
    }
  }
}

function clearCart() {
  setCart([]);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function multiDownload() {
  let cartArray = getCart();
  for (let i = cartArray.length - 1; i >= 0; i--) {
    let link = document.createElement("a");
    link.download = cartArray[i];
    link.href = "/.zip?files=" + encodeURI(cartArray[i]);
    link.click();
    removeFromCart(cartArray[i]);
    await sleep(500);
  }
}

function generateBreadCrumb() {
  function createSeparator() {
    let separator = document.createElement("i");
    separator.className = "fas fa-slash path-separator";
    return separator;
  }
  function createPart(path, txt) {
    let lnk = document.createElement("a");
    lnk.href = path;
    lnk.textContent = txt;
    lnk.onclick = function() {
      event.preventDefault();
      navigateContent(path);
    }
    return lnk
  }
  function createSpecial(path) {
    let special = document.createElement("a");
    special.className = "tooltip tooltip-bottom";
    special.href = "/" + path;
    special.onclick = function() {
      event.preventDefault();
      navigateContent("/" + path);
    }
    let specialIcon = document.createElement("i");
    special.appendChild(specialIcon);
    if (path === ".list") {
      special.setAttribute("data-tooltip", "Cart");
      specialIcon.className = "fas fa-cart-arrow-down";
    }
    else {
      special.setAttribute("data-tooltip", "Download");
      specialIcon.className = "fas fa-download";
    }
    return special;
  }
  let breadcrumb_tree = document.createElement("div");
  breadcrumb_tree.id = "breadcrumb";
  breadcrumb_tree.className = "item";

  let home = document.createElement("a");
  home.className = "tooltip tooltip-bottom";
  home.href = "/";
  home.onclick = function() {
    event.preventDefault();
    navigateContent("/");
  }
  home.setAttribute("data-tooltip", "Home");
  let homeIcon = document.createElement("i");
  homeIcon.className = "fas fa-home";
  home.appendChild(homeIcon);
  breadcrumb_tree.appendChild(home)

  let curPathArray = window.location.pathname.split('/');
  let arrayLength = curPathArray.length;
  let path = "/";
  // Skip first as it is empty
  for (let i = 1; i < arrayLength; i++) {
    if (curPathArray[i] === "")
      continue;
    let breadcrumb_part;
    if (curPathArray[i] === ".list" || curPathArray[i] === ".download") {
      breadcrumb_part = createSpecial(curPathArray[i]);
    }
    else {
      path += curPathArray[i] + "/";
      breadcrumb_part = createPart(path, decodeURI(curPathArray[i]));
    }
    breadcrumb_tree.appendChild(createSeparator());
    breadcrumb_tree.appendChild(breadcrumb_part);
  }
  let breadcrumb = document.getElementById('breadcrumb');
  breadcrumb.parentNode.replaceChild(breadcrumb_tree, breadcrumb);
}

function navigateContent(path, pushState = true) {
  path = decodeURIComponent(path);
  if (path[0] !== '/')
    path = window.location.pathname + path

  let header = document.querySelector('body > .header');
  header.classList.toggle('loading');

  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {

    if(xhr.readyState === 4) {
      if (xhr.status >= 200 && xhr.status < 300) {
        if (pushState)
          history.pushState(null, null, path);

        let content = document.getElementById('content')
        content.parentNode.replaceChild(xhr.response.getElementById('content'), content);
      }
      else {
        console.error("Failed to load new page");
        console.error(xhr);
      }
      header.classList.toggle('loading');
      scroll(0,0);
      generateBreadCrumb();
    }
  };
  xhr.open("GET", path);
  xhr.responseType = "document";
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  xhr.send();
}

window.addEventListener("popstate", function(e) {
  navigateContent(location.pathname, false);
});
