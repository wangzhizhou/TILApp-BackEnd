FROM swift:5.9

WORKDIR /package

COPY . ./

CMD ["swift", "test", "--enable-test-discovery"]