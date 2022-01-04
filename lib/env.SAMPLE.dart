// fill the first four variables, then remove THE .SAMPLE from the name
const envMediaBrowserToken = '';
const envJellyfinUrl = '';
const envUserId = '';
const envLibraryId = '';

const reqHeaders = {'X-MediaBrowser-Token': envMediaBrowserToken};
final reqBaseUrl =
    envJellyfinUrl.endsWith('/') ? envJellyfinUrl : envJellyfinUrl + "/";
