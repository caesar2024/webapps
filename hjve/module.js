function lin(n) {
    return Array(n).fill(0).map(function (x, i) { return i; });
}

function logspace(x, y, len) {
    var arr, end, tmp, d;
    var a = Math.log10(x);
    var b = Math.log10(y);
    if (len <= 0) {
        return [];
    }
    end = len - 1;
    d = (b - a) / end;
    arr = new Array(len);
    tmp = a;
    arr[0] = Math.pow(10, tmp);
    for (var i = 1; i < end; i++) {
        tmp += d;
        arr[i] = Math.pow(10, tmp);
    }
    arr[end] = Math.pow(10, b);
    return arr;
}

function vecmul(a,b) {
    let result = a.map((e,i) => e * b[i])
    return result
}

function vecdiv(a,b) {
    let result = a.map((e,i) => e / b[i])
    return result
}

function vecsub(a,b) {
    let result = a.map((e,i) => e - b[i])
    return result
}

function derivative(f) {
    var h = 0.001;
    return function(x) { return (f(x + h) - f(x - h)) / (2 * h); };
}
