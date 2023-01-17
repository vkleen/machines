final: prev: {
  todoman = prev.todoman.overridePythonAttrs
    (o: {
      doCheck = false;
    });
}
