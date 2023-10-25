const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const openssl = b.dependency("openssl", .{});

    const lib = b.addStaticLibrary(.{
        .name = "uSockets",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/bsd.c" },
    });

    lib.defineCMacro("WITH_OPENSSL", null);

    lib.addCSourceFiles(&.{
        "src/context.c",
        "src/loop.c",
        "src/quic.c",
        "src/socket.c",
        "src/udp.c",
        "src/crypto/openssl.c",
        "src/eventing/epoll_kqueue.c",
        "src/eventing/gcd.c",
        "src/eventing/libuv.c",
        "src/io_uring/io_context.c",
        "src/io_uring/io_loop.c",
        "src/io_uring/io_socket.c",
    }, &.{});

    lib.addCSourceFiles(&.{
        "src/crypto/sni_tree.cpp",
    }, &.{
        "-std=c++17",
    });

    lib.linkLibCpp();
    lib.linkLibC();

    lib.addIncludePath(.{ .path = "capi" });
    lib.addIncludePath(.{ .path = "src" });

    lib.linkLibrary(openssl.artifact("ssl"));
    lib.installHeader("src/libusockets.h", "libusockets.h");

    b.installArtifact(lib);
}
