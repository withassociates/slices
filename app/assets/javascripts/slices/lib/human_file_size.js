window.humanFileSize = function(bytes) {
  bytes = parseInt(bytes, 10);

  if (isNaN(bytes)) return 'N/A';

  var ONE_KB = 1024,
      ONE_MB = ONE_KB * 1024,
      ONE_GB = ONE_MB * 1024;

  if (bytes >= ONE_GB) return (bytes / ONE_GB).toFixed(2) + ' GB';
  if (bytes >= ONE_MB) return (bytes / ONE_MB).toFixed(2) + ' MB';
  if (bytes >= ONE_KB) return Math.floor(bytes / ONE_KB) + ' KB';

  return bytes + 'b';
}

