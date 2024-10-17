const optionsContainer = document.getElementById('options-container');
let typeWriterRunning = false;
let timer = null;
let mousedownListener = null;

function display(bool, data) {
  if (bool) {
    if (data.info.color) {
      updateColor(data.info.color);
    }
	if (!$("#radial").hasClass("opened")) {
      $("#radial").addClass("opened");
      $("#radial").addClass("showing");
    }
    $("#radial").show();
    removeOptions();
    const txt = data.info.content;
    const element = document.getElementById('content');
    const headerContainer = document.getElementById('header');
    headerContainer.textContent = data.info.title;
    typeWriter(element, txt, 50, data.options.options);
  } else {
    resetColor();
	$("#radial").removeClass("opened");
	$("#radial").removeClass("showing");
    $("#radial").hide();
    document.getElementById('content').innerHTML = '';
    removeOptions();
  }
}

function updateColor(newColor) {
  document.styleSheets[0].addRule(`#options-container:hover::-webkit-scrollbar-thumb`, `background-color: ${newColor}`);
  document.styleSheets[0].addRule(`.item:hover`, `background-color: ${newColor}`);
  document.styleSheets[0].addRule(`.item-icon`, `background-color: ${newColor}`);
  document.styleSheets[0].addRule(`.item:hover .item-icon`, `color: ${newColor}`);
  document.styleSheets[0].addRule(`#close-button`, `background-color: ${newColor}`);
  document.styleSheets[0].addRule(`#close-button:hover span`, `color: ${newColor}`);
}

function resetColor() {
  document.styleSheets[0].addRule(`#options-container:hover::-webkit-scrollbar-thumb`, `background-color: #ad8f1a`);
  document.styleSheets[0].addRule(`.item:hover`, `background-color: #ad8f1a`);
  document.styleSheets[0].addRule(`.item-icon`, `background-color: #ad8f1a`);
  document.styleSheets[0].addRule(`.item:hover .item-icon`, `color: #ad8f1a`);
  document.styleSheets[0].addRule(`#close-button`, `background-color: #ad8f1a`);
  document.styleSheets[0].addRule(`#close-button:hover span`, `color: #ad8f1a`);
}

window.addEventListener('message', function(event) {
	const data = event.data;
	if (data.status == true) {
		display(true, data);
	} else {
		display(false);
	}
});

document.onkeyup = function (event) {
	const charCode = event.key;
	if (charCode == "Escape") {
		$.post(`http://${GetParentResourceName()}/exit`, JSON.stringify({}));
		display(false);
	}
};

$("#close-button").click(function () {
	stopTypeWriter();
	$.post(`http://${GetParentResourceName()}/exit`, JSON.stringify({}));
	display(false);
});

function show(id) {
	$.post(`http://${GetParentResourceName()}/selectTarget`, JSON.stringify({id}));
}

function createOptionItem(data, id) {
	const item = document.createElement('div');
	item.classList.add('item');
	item.onclick = function() { show(id); };
	const itemContent = document.createElement('div');
	const itemTop = document.createElement('div');
	itemTop.classList.add('item-top');
	itemContent.style.display = 'flex';
	itemContent.style.flexDirection = 'column';
	itemContent.style.alignItems = 'center';
	itemContent.style.textAlign = 'center';
	itemContent.style.flex = '1';

	let itemText;
	let itemImage;
	let itemIcon;

	if (data.icon) {
		itemIcon = document.createElement('div');
		itemIcon.classList.add('item-icon');
		itemIcon.innerHTML = `<i class="${data.icon}"></i>`;
		itemTop.appendChild(itemIcon);
	}

	if (data.label) {
		itemText = document.createElement('div');
		itemText.classList.add('item-text');
		itemText.textContent = data.label;
		itemTop.appendChild(itemText);
	}

	item.appendChild(itemTop);

	if (data.image) {
		itemImage = document.createElement('img');
		itemImage.src = data.image;
		item.appendChild(itemImage);
	}

	return item;
}

function removeOptions() {
  optionsContainer.innerHTML = '';
}

function preload_images(data) {
  for (const itemData of data) {
    const img = new Image();
    img.src = itemData.image;
  }
}

function stopTypeWriter() {
	clearTimeout(timer);
	timer = null;
	typeWriterRunning = false;
	document.removeEventListener('mousedown', mousedownListener);
}

function typeWriter(element, text, speed, data) {
  preload_images(data);
  if (typeWriterRunning) {
	clearTimeout(timer);
	timer = null;
	typeWriterRunning = false;
  }

  let index = 0;
  let skipEffect = false;

  mousedownListener = (e) => {
	if (e.button === 0 && !e.target.classList.contains('option-item') && e.target.id !== 'close-button') { // 0 is the left mouse button
	  skipEffect = true;
	}
  };

  document.addEventListener('mousedown', mousedownListener);

  function type() {
	typeWriterRunning = true;

	if (skipEffect) {
	  element.innerText = text;
	  skipEffect = false;
	  typeWriterRunning = false;
	  appendOptions();
	  return;
	}

	if (index < text.length) {
	  element.innerText = text.substring(0, index + 1);
	  index++;
	  timer = setTimeout(type, speed);
	} else {
	  typeWriterRunning = false;
	  appendOptions();
	}
  }
  function appendOptions() {
	$.post(`http://${GetParentResourceName()}/stopanim`, JSON.stringify({}));
	setTimeout(() => {
		for (let [index, itemData] of Object.entries(data)) {
		  const item = createOptionItem(itemData, index);
		  optionsContainer.appendChild(item);
		  setTimeout(() => {
			item.classList.add('animate');
		  }, index * 50);
		}
	}, 100);
  }

  type();
}