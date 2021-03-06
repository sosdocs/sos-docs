

{% macro css() %}

<style>

.toc-container {
    margin-top: 80px;
    max-height: calc(100% - 140px);
}

.toc-wrapper {
    overflow-y: scroll;
}

.toc-header {
    background-color: #c3dbf7;
    height: 60px;
}

.toc-header .nav-home {
    float: left;
    padding-left: 20px;
}
.toc-header .nav-buttons {
    float: right;
    padding-right: 30px;
    outline: none;
}

.toc-header .nav-buttons button {
    background: transparent;
    border: none;
}

.toc-header .nav-buttons button:focus {
    outline: 0;
}

.nav > li > a:hover {
    background-color: #7b7b7b  !important;
    color: white !important;
}

.toc-container .nav > li > a {
    padding-top: 5px;
    padding-bottom: 5px;
}

.toc-header .fa {
    font-size: 38px;
    color: white;
    padding-top: 8px;
    padding-bottom: 8px;
    padding-left: 10px;
}

.toc-header .fa:hover {
    color: #6197d5 ;
}


.toc-before {
    background: lightgray;
}


.toc-after {
    background: lightgray;
}

</style>

{% endmacro %}



{% macro js(master_list, header_list, notebook_id) %}


<script>

function add_nav_header() {
    let url = window.location.pathname;
    let filename = url.substring(url.lastIndexOf('/')+1);

    let header = document.getElementsByClassName('toc-header');
    if (!header) {
        return;
    }
    let beforetoc = document.getElementsByClassName('toc-before');
    let aftertoc = document.getElementsByClassName('toc-after');
    let toc = document.getElementById('toc');

    let idx = {{ master_list }}.indexOf(filename.replace(/\.[^/.]+$/, ""))
    let prev_link = ''
    let next_link = ''
    if (idx != 0) {
        prev_link = `<button title="{{ '${' }}{{ header_list }}[idx - 1]}" onclick="loadPage('{{ '${' }}{{ master_list }}[idx - 1]}')" ><i class="fa fa-arrow-circle-left nav-left"></i></button>`;
    }
    if (idx != {{ master_list }}.length - 1) {
        next_link = `<button title="{{ '${' }}{{ header_list }}[idx + 1]}" onclick="loadPage('{{ '${' }}{{ master_list }}[idx + 1]}')" ><i class="fa fa-arrow-circle-right nav-right"></i></button>`;
    }
    header[0].outerHTML = `
        <div class="toc-header">
            <div class="row">
                <div class="nav-home">
                    <a href="https://vatlab.github.io/sos-docs/notebook.html#content"><i class="fa fa-home"></i></a>
                </div>
                <div class="nav-buttons">
                        ${prev_link}
                        ${next_link}
                </div>
            </div>
        </div>
    `
    pre_elements = '<div class="toc-before"><ul class="toc-list nav nav-list">';
    for (let i = 0; i < idx; ++i) {
        pre_elements += `<li class="toc-item"><a href="javascript:loadPage('{{ '${' }}{{ master_list }}[i]}');">${ {{header_list}}[i]}</a></li>`;
    }

    pre_elements += '</ul></div>';
    beforetoc[0].outerHTML = pre_elements;

    post_elements = '<div class="toc-after"><ul class="toc-list nav nav-list">';
    for (let i = idx + 1; i < {{master_list}}.length; ++i) {
        post_elements += `<li class="toc-item"><a href="javascript:loadPage('{{ '${' }}{{ master_list }}[i]}');">${ {{header_list}}[i]}</a></li>`;
    }
    post_elements += '</ul></div>';
    aftertoc[0].outerHTML = post_elements;

    toc.scrollIntoView();
}

function replacePage(title, url, newdoc, pushState) {
    window.aa = newdoc;
    // step 1, find existing cells
    let nc = document.getElementById('{{ notebook_id}}');
    nc.innerHTML = '';
    var root = document.createElement("div");
    root.innerHTML = newdoc;
    // let us find notebook-container in the root
    let new_nc = root.querySelector('.{{ notebook_id}}');

    while (new_nc.childNodes.length > 0) {
        nc.appendChild(new_nc.childNodes[0]);
    }
    // scroll to top
    nc.parentElement.scrollIntoView()

    if (pushState) {
        history.pushState({'title': title, 'url': url}, title, url);
    }
    // update URL
    add_nav_header()
    // nav_header
    fixIDsForToc();
    tocbot.refresh();
    // CM
    if (typeof applySoSMode === "function") {
        applySoSMode();
    }
}

function loadPage(name, pushState=true) {
    let xhr = new XMLHttpRequest();
    let href = window.location.href;
    let base = href.substring(0, href.lastIndexOf('/'));
    let url = `${base}/${name}.html`;
    xhr.open('GET', url);
    xhr.onload = function(e) {
        if (xhr.status === 200) {
            replacePage(name, url, xhr.responseText, pushState);
        }
        else {
            console.log(`failed to load ${url}`);
        }
    };
    xhr.onerror = function (e) {
        console.log('failed')
    }
    xhr.send();
}

add_nav_header();

function navBack(event) {
    if (event.state && event.state.title) {
        console.log(`load ${event.state.title}`)
        loadPage(event.state.title, false);
    }
    // else {
    //    window.open(document.location);
    // }
    //console.log(event)
    //console.log(`Location ${document.location}`)
}

window.addEventListener('popstate', navBack);

</script>

{% endmacro %}
