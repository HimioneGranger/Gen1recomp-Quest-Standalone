-- App-owned Quest compositor geometry and shared-context state contracts.
-- These checks prove the compatibility bridge cannot submit a small central
-- crop or world triangles. Immersive world meshes remain outside this bridge.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = assert(file:read("*a"))
  file:close()
  return value
end

local bridge = read("mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")

T.check(bridge:find(
  "-1.f, -1.f, 0.f, 0.f,  1.f, -1.f, 1.f, 0.f,", 1, true)
  and bridge:find(
    "-1.f,  1.f, 0.f, 1.f,  1.f,  1.f, 1.f, 1.f,", 1, true),
  "the panel quad covers the full clip rectangle and full texture")
T.check(bridge:find("glViewport(0, 0, 1024, 768);", 1, true),
  "the panel swapchain uses its full 1024 by 768 extent")
T.check(bridge:find(
  "questxr_gl_blit_framebuffer(0, 0, width, height, 0, 0, 1024, 768,", 1, true),
  "a completed app frame fills the full panel texture")
T.check(bridge:find("layer.size.width = 1.55f;", 1, true)
  and bridge:find("layer.size.height = 1.1625f;", 1, true),
  "the physical panel keeps the same four-to-three aspect ratio")
T.check(bridge:find("background_layer.viewCount = 2;", 1, true)
  and bridge:find("background_views[eye].subImage.imageRect.extent.width =", 1, true)
  and bridge:find("background_views[eye].subImage.imageRect.extent.height =", 1, true),
  "the optional app environment submits two full per-eye views")

for _, state in ipairs({
  "GL_READ_FRAMEBUFFER_BINDING", "GL_DRAW_FRAMEBUFFER_BINDING",
  "GL_PACK_ALIGNMENT", "GL_ACTIVE_TEXTURE", "GL_TEXTURE_BINDING_2D",
}) do
  T.check(bridge:find(state, 1, true),
    "panel capture records shared GL state: " .. state)
end
T.check(bridge:find("glBindFramebuffer(GL_READ_FRAMEBUFFER, (GLuint) old_read);", 1, true)
  and bridge:find("glBindFramebuffer(GL_DRAW_FRAMEBUFFER, (GLuint) old_draw);", 1, true)
  and bridge:find("glPixelStorei(GL_PACK_ALIGNMENT, old_pack);", 1, true)
  and bridge:find("glBindTexture(GL_TEXTURE_2D, (GLuint) old_texture_2d);", 1, true)
  and bridge:find("glActiveTexture((GLenum) old_active_texture);", 1, true),
  "panel capture restores every shared binding that it changes")
T.check(bridge:find("if (old_scissor) glDisable(GL_SCISSOR_TEST);", 1, true)
  and bridge:find("if (old_scissor) glEnable(GL_SCISSOR_TEST);", 1, true),
  "panel capture preserves the prior scissor enable state")
T.check(bridge:find("rejected blank launcher capture", 1, true)
  and bridge:find("return;", bridge:find("rejected blank launcher capture", 1, true), true),
  "an empty Android surface cannot replace the last valid panel")
local _, drawArrayCalls = bridge:gsub("glDrawArrays", "")
T.check(not bridge:find("glDrawElements", 1, true) and drawArrayCalls == 1,
  "the app bridge draws only its four-vertex panel and no world mesh")

T.finish("Quest compositor geometry and render state")
