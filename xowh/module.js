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



function lnmode(A, x) {
    var prefactor = A[0] / (Math.sqrt(2 * Math.PI) * Math.log(A[2]));
    var div = 2 * Math.pow(Math.log(A[2]), 2);
    var psd = x.map(function (x) { return prefactor * Math.exp(-Math.pow(Math.log(x / A[1]), 2) / div); });
    return psd;
}


function gamma_drop(A, x) {
    let psd = x.map(function (x) { return A[0] * Math.pow(x, A[1]) * Math.exp(-A[2] * x); });
    return psd;
}

function Dμm_to_xg(D) {
    let result = Math.PI/ 6.0 * Math.pow(D * 1e-6, 3.0) * 1000000.0 
    return result
}

function xg_to_Dμm(x) {
    let result = Math.pow(x / 1e6 * 6.0 / Math.PI, 1.0 / 3.0) * 1e6
    return result
} 

function Ap(Nc, ν, B) {
    let result = Nc / (math.gamma(ν + 1.0) / Math.pow(B, ν + 1.0))
    return result
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


var prevGuess = 10 
var precision = 1e-3

function newtonsMethod(f, guess) {
    if (Math.abs(prevGuess - guess) > precision) {
        prevGuess = guess;
        var approx = guess - (f(guess) / derivative(f)(guess));
        return newtonsMethod(f, approx);
    } else {
        return guess;
    }
}
