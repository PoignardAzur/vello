// SPDX-License-Identifier: Apache-2.0 OR MIT OR Unlicense

struct TagMonoid {
    trans_ix: u32,
    // TODO: I don't think pathseg_ix is used.
    pathseg_ix: u32,
    pathseg_offset: u32,
#ifdef full
    style_ix: u32,
    path_ix: u32,
#endif
}

let PATH_TAG_SEG_TYPE = 3u;
let PATH_TAG_LINETO = 1u;
let PATH_TAG_QUADTO = 2u;
let PATH_TAG_CUBICTO = 3u;
let PATH_TAG_F32 = 8u;
let PATH_TAG_TRANSFORM = 0x20u;
#ifdef full
let PATH_TAG_PATH = 0x10u;
let PATH_TAG_STYLE = 0x40u;
#endif
let PATH_TAG_SUBPATH_END = 4u;

// Size of the `Style` data structure in words
let STYLE_SIZE_IN_WORDS: u32 = 2u;

let STYLE_FLAGS_STYLE: u32 = 0x80000000u;
let STYLE_FLAGS_FILL: u32 = 0x40000000u;
let STYLE_MITER_LIMIT_MASK: u32 = 0xFFFFu;

let STYLE_FLAGS_START_CAP_MASK: u32 = 0x0C000000u;
let STYLE_FLAGS_END_CAP_MASK: u32 = 0x03000000u;

let STYLE_FLAGS_CAP_BUTT: u32 = 0u;
let STYLE_FLAGS_CAP_SQUARE: u32 = 0x01000000u;
let STYLE_FLAGS_CAP_ROUND: u32 = 0x02000000u;

let STYLE_FLAGS_JOIN_MASK: u32 = 0x30000000u;
let STYLE_FLAGS_JOIN_BEVEL: u32 = 0u;
let STYLE_FLAGS_JOIN_MITER: u32 = 0x10000000u;
let STYLE_FLAGS_JOIN_ROUND: u32 = 0x20000000u;

// TODO: Declare the remaining STYLE flags here.

fn tag_monoid_identity() -> TagMonoid {
    return TagMonoid();
}

fn combine_tag_monoid(a: TagMonoid, b: TagMonoid) -> TagMonoid {
    var c: TagMonoid;
    c.trans_ix = a.trans_ix + b.trans_ix;
    c.pathseg_ix = a.pathseg_ix + b.pathseg_ix;
    c.pathseg_offset = a.pathseg_offset + b.pathseg_offset;
#ifdef full
    c.style_ix = a.style_ix + b.style_ix;
    c.path_ix = a.path_ix + b.path_ix;
#endif
    return c;
}

fn reduce_tag(tag_word: u32) -> TagMonoid {
    var c: TagMonoid;
    let point_count = tag_word & 0x3030303u;
    c.pathseg_ix = countOneBits((point_count * 7u) & 0x4040404u);
    c.trans_ix = countOneBits(tag_word & (PATH_TAG_TRANSFORM * 0x1010101u));
    let n_points = point_count + ((tag_word >> 2u) & 0x1010101u);
    var a = n_points + (n_points & (((tag_word >> 3u) & 0x1010101u) * 15u));
    a += a >> 8u;
    a += a >> 16u;
    c.pathseg_offset = a & 0xffu;
#ifdef full
    c.path_ix = countOneBits(tag_word & (PATH_TAG_PATH * 0x1010101u));
    c.style_ix = countOneBits(tag_word & (PATH_TAG_STYLE * 0x1010101u)) * STYLE_SIZE_IN_WORDS;
#endif
    return c;
}
