'use strict';

// Global Variables
const baseURL = `http://www.omdbapi.com/?apikey=`;
const key = `7c1228f1`;
const header = document.querySelector('header');
const h1 = document.querySelector('h1');
let h2 = document.createElement('h2');
const searchBox = document.getElementById('s');
const form = document.querySelector('form');
const checkbox = document.querySelector('[type=checkbox]');
const results = document.querySelector('#results');
let lastMovie;
let page;
let endpoint;
let movieCounter = 0;
const watcher = new IntersectionObserver(handleScroll);

//Global Listeners

if(form) {
  form.addEventListener('submit', handleForm);
}

checkbox.addEventListener('change', handleCheckbox);


//Initialize Page
loadPage();

/**
 * in the case of persistent data, loads the results from a previous search term upon loading the page
 * 
 * @returns to break out of the function in the case of no persistent data, as there would be nothing to load
 */
function loadPage(){
  page = 1;
  const savedSearch = localStorage.getItem('search term');
  if(!savedSearch) {return}
  searchBox.value = savedSearch;
  endpoint = `${baseURL}${key}&s=${savedSearch}&page=${page}`;
  getMovies(savedSearch, endpoint);
}

/**
 * Prevents default form behavior, removes previous search results, updates the status of the checkbox, constructs an endpoint, and calls the main getMovies function by sending it the search term and the constructed endpoint
 * 
 * @param {event} submit - the submit "Search" event of the form
 */
function handleForm(submit) {
  submit.preventDefault();
  removeSearchResults();
  handleCheckbox();
  const searchTerm = searchBox.value;
  page = 1;
  endpoint = `${baseURL}${key}&s=${searchTerm}&page=${page}`;
  getMovies(searchTerm, endpoint);
}

/**
 * Removes the heading and movie results from a previous search
 */
function removeSearchResults() {
  if(header.querySelector('h2')) {
    header.querySelector('h2').remove();
  }
  if(results.querySelectorAll('section').length > 0){
    results.querySelectorAll('section').forEach(section => section.remove());
    movieCounter = 0;
  }
}

/**
 * 
 * uses a searchTerm and an endpoint to fetch movie data with a given search term from the OMDb API and render the results on the page
 * 
 * @param {string} searchTerm - the search term entered in the search box by the user
 * @param {string} endpoint - the url used to fetch data from the API 
 * 
 * @returns to break out of the function if there is an error with the promise/fetching data from the API
 */
async function getMovies(searchTerm, endpoint) {
  const moviePromise = await fetch(endpoint);
  const serverResponse = await moviePromise.json();

  if(!moviePromise.ok) {
    const errorMsg = serverResponse.Error;
    renderError(errorMsg);
    return;
  }

  let total = serverResponse.totalResults;
  if(total === undefined) {
    total = 0;
    displayResults(searchTerm, total);
  } else {
    displayResults(searchTerm, total);
  
    serverResponse.Search.forEach(movieObject => {
      const title = movieObject.Title;
      let year = movieObject.Year;
      if(year.length === 5) {
        year = year + `present`;  
      }
      let poster = movieObject.Poster;
      if(!poster || poster === 'N/A') {
        poster = `https://placehold.co/150x200?text=No Poster`;
      }
      const section = document.createElement('section');
      results.appendChild(section);
      const div = document.createElement('div');
      section.appendChild(div);
      const h3 = document.createElement('h3');
      h3.textContent = title;
      div.appendChild(h3);
      const p = document.createElement('p');
      p.textContent = `Year released: ${year}`;
      div.appendChild(p);
      const img = document.createElement('img');
      img.src = poster;
      img.setAttribute('alt', `A poster for the movie ${title}.`);
      div.appendChild(img);
      movieCounter++;
    });
    if (movieCounter == total) {
      watcher.disconnect();
      noMore();
      return;
    } else {
        page++;
        watchForLastMovie();
        loadMore();
    }
  }
}

/**
 * Connects the watcher to the target lastMovie to activate the intersection observer function
 */
function watchForLastMovie() {
  lastMovie = results.querySelector('section:last-of-type');
  watcher.observe(lastMovie);
}

/**
 * Changes the loadmore section to display:flex
 */
function loadMore(){
  document.getElementById('loadmore').style.display = 'flex';
}

/**
 * Changes the loadmore section text to 'no more results'
 */
function noMore(){
  document.getElementById('loadmore').textContent = 'No more results';
}

/**
 * Renders the total number of results in the header for a given search term
 * 
 * @param {string} searchTerm - the search term inputted by the user or saved in local storage 
 * @param {string} total - the number of movie results fetched from the API based on the searchTerm
 */
function displayResults(searchTerm, total) {
  const displayedSearchTerm = document.createElement('span');
  displayedSearchTerm.textContent = searchTerm;
  displayedSearchTerm.setAttribute('id', 'term');
  h2.textContent = `${total} results for `;
  h2.appendChild(displayedSearchTerm);
  h1.insertAdjacentElement('afterend', h2);
}

/**
 * Adds or removes persistent data depending on the checked status of the "save my search" checkbox
 */
function handleCheckbox() {
  if(checkbox.checked){
    localStorage.setItem('search term', searchBox.value);
  }
  if(!checkbox.checked){
    localStorage.removeItem('search term');
  }
}

/**
 * Renders an error message in the header in the case of an error with the promise/fetching data from the API
 * 
 * @param {string} err - the error message within the server's response
 */
function renderError(err) {
 h2.textContent = `Error: ${err}`;
 h1.insertAdjacentElement('afterend', h2);
}

/**
 * tests if the target is intersecting with the viewport and calls getMovies() if so
 * 
 * @param {array} payload - an array of IntersectionObserverEntry objects
 */
function handleScroll(payload) {
   if(payload[0].isIntersecting) {
    endpoint = `${baseURL}${key}&s=${searchBox.value}&page=${page}`;
    getMovies(searchBox.value, endpoint);
   }
}
