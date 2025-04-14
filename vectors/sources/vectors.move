module interest_vectors::vectors;

public macro fun do<$T, $R: drop>($v: vector<$T>, $f: |$T, u64| -> $R) {
    let mut v = $v;
    v.reverse();
    v.length().do!(|i| $f(v.pop_back(), i));
    v.destroy_empty();
}

public macro fun do_ref<$T, $R: drop>($v: &vector<$T>, $f: |&$T, u64| -> $R) {
    let v = $v;
    v.length().do!(|i| $f(&v[i], i))
}

public macro fun do_mut<$T, $R: drop>($v: &mut vector<$T>, $f: |&mut $T, u64| -> $R) {
    let v = $v;
    v.length().do!(|i| $f(&mut v[i], i))
}

public macro fun map<$T, $U>($v: vector<$T>, $f: |$T, u64| -> $U): vector<$U> {
    let v = $v;
    let mut r = vector[];
    do!(v, |e, i| r.push_back($f(e, i)));
    r
}

public macro fun map_ref<$T, $U>($v: &vector<$T>, $f: |&$T, u64| -> $U): vector<$U> {
    let v = $v;
    let mut r = vector[];
    do_ref!(v, |e, i| r.push_back($f(e, i)));
    r
}

public macro fun filter<$T: drop>($v: vector<$T>, $f: |&$T, u64| -> bool): vector<$T> {
    let v = $v;
    let mut r = vector[];
    do!(v, |e, i| if ($f(&e, i)) r.push_back(e));
    r
}

public macro fun fold<$T, $Acc>($v: vector<$T>, $init: $Acc, $f: |$Acc, $T, u64| -> $Acc): $Acc {
    let v = $v;
    let mut acc = $init;
    do!(v, |e, i| acc = $f(acc, e, i));
    acc
}
